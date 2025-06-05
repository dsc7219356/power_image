/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { PowerImageResult } from '../loader/PowerImageResult';
import { PowerImageEngineContext } from '../PowerImageEngineContext';
import { PowerImageBaseRequest } from './PowerImageBaseRequest';
import { image } from '@kit.ImageKit';
import PowerImage from "libpowerimage.so"

const TAG = "PowerImageExternalRequest";

export class PowerImageExternalRequest extends PowerImageBaseRequest {
  private static FLUTTER_PIXEL_FORMAT_RGBA8888: number = 0;
  private static FLUTTER_PIXEL_FORMAT_BGRA8888: number = 1;
  private stoped?: boolean;
  private bitmap: image.PixelMap | null = null;
  private bitmapWidth?: number;
  private bitmapHeight?: number;
  private flutterPixelFormat?: number;
  private rowBytes?: number;
  private handle?: number;
  private length?: number;

  constructor(context: PowerImageEngineContext, args: Map<string, Object>) {
    super(context, args);
  }

  public async onLoadResult(result: PowerImageResult): Promise<void> {
    super.onLoadResult(result);
    if (result == null) {
      this.onLoadFailed(TAG + ":onLoadResult(PowerImageResult result) result is null");
      return;
    }
    if (!result.success) {
      this.onLoadFailed(result.errMsg!);
      return;
    }
    if (this.stoped) {
      this.onLoadFailed(TAG + ":onLoadResult isStopped");
      return;
    }
    if (result.image == null || !result.image.isValid()) {
      this.onLoadFailed(TAG + ":onLoadResult FlutterImage/bitmap is null or bitmap has recycled");
      return;
    }
    // Drawable imageDrawable = result.image.getDrawable();
    // if(result.image instanceof FlutterMultiFrameImage){
    //   bitmap = ((FlutterMultiFrameImage) result.image).getCurrentFrame(imageDrawable);
    // }else {
    //   if(!(imageDrawable instanceof BitmapDrawable)){
    //     onLoadFailed(TAG + ":onLoadResult drawable isn't a BitmapDrawable");
    //     return;
    //   }
    //   this.bitmap = ((BitmapDrawable) imageDrawable).getBitmap();
    // }
    if (result.bitMap != null) {
      this.bitmap = result.bitMap;
    }
    if (this.bitmap == null) {
      this.onLoadFailed(TAG + ":onLoadResult bitmap is null or bitmap has recycled");
      return;
    }
    // convert to ARGB_8888 for flutter decoding
    // if (this.bitmap.getConfig()  != image.PixelMapFormat.BGRA_8888) {
    //   if ( this.bitmap.getConfig() == image.PixelMapFormat.UNKNOWN) {
    //     this.onLoadFailed(TAG + ":onLoadResult bitmap config HARDWARE is not supported");
    //     return;
    //   }
    //   this.bitmap = this.bitmap!.copy(Bitmap.Config.ARGB_8888, false);
    // }
    this.handle = PowerImage.getBitmapPixelsPtr(this.bitmap!);
    const imageInfo = await this.bitmap!.getImageInfo();
    this.bitmapWidth = imageInfo.size.width;
    this.bitmapHeight = imageInfo.size.height;
    this.flutterPixelFormat = PowerImageExternalRequest.FLUTTER_PIXEL_FORMAT_RGBA8888;
    //返回位图像素中行之间的字节数
    this.rowBytes = this.bitmap!.getImageInfoSync().stride;
    //返回可用于存储此位图像素的最小字节数。ohos没有找到这个方法
    this.length = this.rowBytes * this.bitmapHeight;//获取图像像素的总字节数
    // this.length = this.bitmap.getByteCount();//Android写法

    this.onLoadSuccess();
  }

  public stopTask(): boolean {
    this.stoped = true;
    this.imageTaskState = PowerImageExternalRequest.REQUEST_STATE_RELEASE_SUCCEED;
    // this.releaseBitmapPixels(this.bitmap!);
    PowerImage.releaseBitmapPixels(this.handle);
    if (this.bitmap != null) {
      this.bitmap!.release();
    }
    this.bitmap = null;
    return true;
  }

  public encode(): Map<string, Object> {
    let encodedRequest: Map<string, Object> = super.encode();
    encodedRequest.set("width", this.bitmapWidth!);
    encodedRequest.set("height", this.bitmapHeight!);
    encodedRequest.set("rowBytes", this.rowBytes!);
    encodedRequest.set("length", this.length!);
    encodedRequest.set("handle", this.handle!);
    encodedRequest.set("flutterPixelFormat", this.flutterPixelFormat!);
    return encodedRequest;
  }

  // public native getBitmapPixelsPtr(bitmap: z): number;

  //Android写法
  // public native long getBitmapPixelsPtr(Bitmap bitmap);
  // 关键字 native 表示该方法是一个本地方法，即其实现是由本地代码提供的，通常是由 C/C++ 语言编写的。
  // 在这种情况下，getBitmapPixelsPtr() 方法的实现不在 Java 代码中，而是在本地代码中，需要通过 JNI（Java Native Interface）来调用。

  // public releaseBitmapPixels(bitmap: image.PixelMap): void;
}