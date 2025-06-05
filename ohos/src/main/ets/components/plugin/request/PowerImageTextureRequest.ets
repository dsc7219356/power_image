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

import { TextureRegistry } from '@ohos/flutter_ohos';
import { PowerImageResult } from '../loader/PowerImageResult';
import { PowerImageDispatcher } from '../dispatcher/PowerImageDispatcher';
import { PowerImageEngineContext } from '../PowerImageEngineContext';
import { PowerImageBaseRequest } from './PowerImageBaseRequest';
import { SurfaceTextureEntry } from '@ohos/flutter_ohos/src/main/ets/view/TextureRegistry';
import { FlutterImage } from '../loader/FlutterImage';
import { FlutterSingleFrameImage } from '../loader/FlutterSingleFrameImage';

const TAG = "PowerImageTextureRequest";

export class PowerImageTextureRequest extends PowerImageBaseRequest {
  public static MAX_RESIZE_HEIGHT = 1920;
  public static MAX_RESIZE_WIDTH = 1920;
  private textureRegistry?: TextureRegistry;
  private stopped?: boolean;
  private textureEntry: SurfaceTextureEntry | null = null;
  // private surface?: Surface;
  private imageTextureWidth?: number;
  private imageTextureHeight?: number;
  private bitmapWidth?: number;
  private bitmapHeight?: number;
  private result?: FlutterSingleFrameImage;
  private textureId = -1;

  constructor(context: PowerImageEngineContext, args: Map<string, Object>, textureRegistry: TextureRegistry) {
    super(context, args);
    this.textureRegistry = textureRegistry;
    this.stopped = false;
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
    if (this.stopped) {
      this.onLoadFailed(TAG + ":onLoadResult isStopped");
      return;
    }
    if (result.image == null || !result.image.isValid()) {
      this.onLoadFailed(TAG + ":onLoadResult FlutterImage/bitmap is null or bitmap has recycled");
      return;
    }
    this.realResult = result;
    this.bitmapWidth = await result.image.getWidth();
    this.bitmapHeight = await result.image.getHeight();
    this.result = result.image as FlutterSingleFrameImage;

    PowerImageDispatcher.getInstance().runOnMainThread(
      () => {
        if (this.textureRegistry != null) {//this.textureEntry == null && this.textureRegistry != null
          // 纹理创建，需要运行在有Looper的线程
          // this.textureEntry = this.textureRegistry.createSurfaceTexture();
          this.textureId = this.textureRegistry.registerPixelMap(this.result!.bitmap);
        }
        if (this.textureRegistry == null) {
          this.onLoadFailed(TAG + ":onLoadResult SurfaceTextureEntry create failed");
          return;
        }
        if (this.stopped) {
          this.onLoadFailed(TAG + ":onLoadResult isStopped 2");
          return;
        }
        // 切到子线程进行图片加载和纹理绘制
        this.performDraw(result.image!);
      }
    );
  }

  public stopTask(): boolean {
    this.stopped = true;
    this.imageTaskState = PowerImageBaseRequest.REQUEST_STATE_RELEASE_SUCCEED;

    PowerImageDispatcher.getInstance().runOnMainThreadDelayed(2000, () => {
      if (this.realResult!.image != null) {
              this.realResult!.image.release();
          }
      if (this.textureEntry != null) {
        // synchronized (textureEntry) {
        try {
          if (this.textureEntry != null) {
            this.textureEntry.release();
            this.textureEntry = null;
          }
          // if (surface != null) {
          //   surface.release();
          //   surface = null;
          // }
        } catch (e) {
        }
        // }
      }
    });
    return true;
  }

  public encode(): Map<string, Object> {
    let encodedRequest: Map<string, Object> = super.encode();
    encodedRequest.set("width", this.bitmapWidth ?? 0);
    encodedRequest.set("height", this.bitmapHeight ?? 0);
    if (this.textureRegistry != null) {
      encodedRequest.set("textureId", this.textureId);
    }
    return encodedRequest;
  }

  // 独立线程中完成纹理绘制工作
  private performDraw(image: FlutterImage) {
    PowerImageDispatcher.getInstance().runOnWorkThread(
      () => {
        if (this.textureRegistry == null || this.stopped || image == null) {
          this.onLoadFailed(TAG + ":performDraw "
            + (this.textureRegistry == null ? "textureRegistry:null " : "")
            + (this.stopped ? "stopped:true " : "")
            + (image == null ? "image:null " : ""));
          return;
        }

        // 显示纹理
        this.checkImageTextureSize(image);
        this.onLoadSuccess();

        // if (surface == null) {
        //   surface = new Surface(textureEntry.surfaceTexture());
        // }
        // this.textureEntry!.surfaceTexture().setDefaultBufferSize(this.imageTextureWidth, this.imageTextureHeight);
        //   if (surface != null && surface.isValid()) {
        //     try {
        //       Rect destRect = new Rect(0, 0, imageTextureWidth, imageTextureHeight);
        //       image.draw(surface, destRect);
        //       this.onLoadSuccess();
        //     } catch (e) {
        //       e.printStackTrace();
        //       this.onLoadFailed(TAG + ":performDraw drawBitmap " + e.getMessage());
        //     }
        //   } else {
        //     this.onLoadFailed(TAG + ":performDraw drawBitmap "
        //       + (surface == null ? "surface:null " : "")
        //       + (surface != null && !surface.isValid() ? "surface invalid" : ""));
        //   }
        // }
      }
    );
  }

  //  确保图片的大小不超过系统的纹理大小的限制
  private async checkImageTextureSize(imageBitmap: FlutterImage) {
    if (imageBitmap == null) {
      return;
    }
    const originWidth: number = await imageBitmap.getWidth();
    const originHeight: number = await imageBitmap.getHeight();


    const widthRatio: number = originWidth / PowerImageTextureRequest.MAX_RESIZE_WIDTH;
    const heightRatio: number = originHeight / PowerImageTextureRequest.MAX_RESIZE_HEIGHT;

    if (widthRatio <= 1 && heightRatio <= 1) {
      this.imageTextureWidth = originWidth;
      this.imageTextureHeight = originHeight;
      return;
    }

    const ratio: number = Math.max(widthRatio, heightRatio);
    this.imageTextureWidth = originWidth / ratio;
    this.imageTextureHeight = originHeight / ratio;
  }
}