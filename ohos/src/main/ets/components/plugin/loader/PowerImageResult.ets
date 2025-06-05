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

import { FlutterImage } from './FlutterImage';
import { FlutterMultiFrameImage } from './FlutterMultiFrameImage';
import { image } from '@kit.ImageKit';
import PowerImagePlugin from '../PowerImagePlugin';
import { FlutterSingleFrameImage } from './FlutterSingleFrameImage';

type ImageOrBitmap = FlutterImage | image.PixelMap | null | undefined;

export class PowerImageResult {
  public image: FlutterImage | null = null;
  public success: boolean | null = null;
  public errMsg: string | undefined = undefined;
  public ext?: ExtData;
  public bitMap: image.PixelMap | null = null;

  // constructor(imageOrBitmap: FlutterImage, success: boolean, errMsg: string, ext: ExtData);
  // constructor(imageOrBitmap: image.PixelMap, success: boolean, errMsg: string, ext: ExtData);
  constructor(imageOrBitmap: ImageOrBitmap, success: boolean, errMsg: string | undefined, ext?: ExtData | undefined) {
    if (imageOrBitmap instanceof FlutterImage) {
      this.image = imageOrBitmap;
      this.success = success;
      this.errMsg = errMsg;
      this.ext = ext;
    } else {
      if (imageOrBitmap != null || imageOrBitmap != undefined) {
        const context = PowerImagePlugin.getContext();
        if (context != null) {
          this.image = new FlutterSingleFrameImage(false, imageOrBitmap);
        } else {
          this.image = null;
        }
        this.bitMap = imageOrBitmap;
      } else {
        this.image = null;
      }
      this.success = success;
      this.errMsg = errMsg;
      this.ext = ext;
    }
  }

  public static genSucRet(bitmap: ImageOrBitmap, ext?: ExtData): PowerImageResult {
    return new PowerImageResult(bitmap, true, undefined, ext);
  }

  public static genFailRet(errMsg: string, ext?: ExtData): PowerImageResult {
    return new PowerImageResult(null, false, errMsg, ext);
  }
}

interface ExtData {
  encode(): Map<string, Object>;
}

class FlutterImageNull extends FlutterImage {
  public getFrameCount(): number {
    throw new Error('Method not implemented.');
  }

  public release(): void {
    throw new Error('Method not implemented.');
  }

  public draw(): void {
    throw new Error('Method not implemented.');
  }
}