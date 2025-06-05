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
import { FlutterException } from '@ohos/flutter_ohos';

export abstract class FlutterImage {
  // protected drawable: Drawable;
  protected needRecycle?: boolean;

  constructor(needRecycle: boolean = false) { //drawable:Drawable
    // if (drawable == null) {
    //   throw new FlutterException('1001','"Empty input drawable!"','');
    // }
    // this.drawable = drawable;
    this.needRecycle = needRecycle;
  }

  /**
   * SingleFrame return 1、 MultiFrame should return actual frameCount
   * @return
   */
  public abstract getFrameCount(): number;

  /**
   * release some object for memory consideration
   */
  public abstract release(): void;

  /**
   * draw the actual bitmap to the surface with specific destRect
   * @param surface
   * @param destRect
   */
  public abstract draw(): void;// surface: Surface, destRect:Rect

  /**
   * Returns the drawable's intrinsic width.
   * @return
   */
  public async getWidth(): Promise<number> {
    // return drawable.getIntrinsicWidth();
    return 0;
  }

  /**
   * Returns the drawable's intrinsic height.
   * @return
   */
  public async getHeight(): Promise<number>{
    // return drawable.getIntrinsicHeight();
    return 0;
  }

  /**
   * Returns the actual drawable(BitmapDrawable、GifDrawable)
   * @return
   */
  // public  getDrawable(): Drawable{
  //   return this.drawable;
  // }

  public isValid(): boolean {
    // return drawable != null;
    return false;
  }
}