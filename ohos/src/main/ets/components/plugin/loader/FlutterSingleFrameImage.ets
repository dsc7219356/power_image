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

import { FlutterImage } from './FlutterImage'
import { image } from '@kit.ImageKit';
import PowerImagePlugin from '../PowerImagePlugin';

export class FlutterSingleFrameImage extends FlutterImage {
  public bitmap: image.PixelMap | null = null;

  // private srcRect: Rect;

  constructor(needRecycle: boolean = false, bitmap:image.PixelMap) {
    super(needRecycle);
    this.bitmap = bitmap;
    // srcRect = new Rect(0, 0, this.getWidth(), this.getHeight());
  }


  public getFrameCount(): number {
    return 1;
  }

  public async release(): Promise<void> {
    if (this.bitmap != null) {//this.needRecycle && this.bitmap != null
      const result: void = await new Promise((re: Function) => {
        this.bitmap!.release();
        this.bitmap = null;
        re();
      })
    }
  }

  public async getWidth(): Promise<number> {
    const imageInfo = await this.bitmap!.getImageInfo()
    return imageInfo.size.height;
  }

  public async getHeight(): Promise<number> {
    const imageInfo = await this.bitmap!.getImageInfo()
    return imageInfo.size.height;
  }

  public draw(): void {
    const settings: RenderingContextSettings = new RenderingContextSettings(true);
    const context: CanvasRenderingContext2D = new CanvasRenderingContext2D(settings)
    // const contex =  PowerImagePlugin.getContext();
    const img: ImageBitmap = new ImageBitmap(this.bitmap!)
    context.drawImage(img, 0, 0, 500, 500, 0, 0, 400, 200);
    // ImageBitmap
    // final Canvas canvas = surface.lockCanvas(null);
    // canvas.drawBitmap(bitmap, srcRect, destRect, null);
    // surface.unlockCanvasAndPost(canvas);
  }

  public isValid(): boolean {
    // return this.bitmap != null && this.bitmap!.isRecycled();
    return (this.bitmap != null || this.bitmap != undefined);
  }
}
