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
import { image } from '@kit.ImageKit';

export abstract class FlutterMultiFrameImage extends FlutterImage{
  private static TAG = "FlutterMultiFrameImage";

  // private static  gAnimateScheduler?: Handler;

  private curBitmapRef?: image.PixelMap;

  // private surface?:Surface;
  // private destRect?: Rect;
  private released: boolean = false;
  // private painter?:Paint;
  // private srcRect: Rect;

  constructor(needRecycle: boolean = false) {
    super(needRecycle);
    // drawable.setCallback(this);
    // srcRect = new Rect(0, 0, getWidth(), getHeight());
  }


}