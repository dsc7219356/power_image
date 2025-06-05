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

import { display } from '@kit.ArkUI';

export class PowerImageRequestConfig {
  public static RENDERING_TYPE_EXTERNAL: string = "external";
  public static RENDERING_TYPE_TEXTURE: string = "texture";

  public src?: Map<string, Object> | undefined = undefined;
  public imageType?: string;
  public renderingType?: string;
  public width?: number;
  public height?: number;
  public originWidth?: number;
  public originHeight?: number;

  public static requestConfigWithArguments(args: Map<string, Object>): PowerImageRequestConfig{
    let src: Map<string, Object> = args.get("src") as Map<string, Object>;
    let imageType: string = args.get("imageType") as string;
    let renderingType: string =  args.get("renderingType") as string;
    let width: number = .0;
    if (args.get("width") instanceof Number) {
      width = args.get("width") as number;
    }
    let height: number = .0;
    if (args.get("height") instanceof Number) {
      height = args.get("height")  as number;
    }
    let scale: number = display.getDefaultDisplaySync().scaledDensity;
    // let scale: number = Resources.getSystem().getDisplayMetrics().density;

    let config: PowerImageRequestConfig = new PowerImageRequestConfig();
    config.src = src;
    config.imageType = imageType;
    config.renderingType = renderingType;
    config.width = (width * scale) as number;
    config.height = (height * scale) as number;
    config.originWidth = width as number;
    config.originHeight = height as number;
    return config;
  }

  public  srcString(): string | null {
    return this.src != null ? this.src.get("src") as string : null;
  }

  public  isExternal(): boolean {
    return this.renderingType == PowerImageRequestConfig.RENDERING_TYPE_EXTERNAL;
  }

  public  isTexture(): boolean {
    return this.renderingType == PowerImageRequestConfig.RENDERING_TYPE_TEXTURE;
  }
}