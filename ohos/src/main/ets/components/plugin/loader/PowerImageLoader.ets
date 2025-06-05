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
import { PowerImageRequestConfig } from '../request/PowerImageRequestConfig';
import { PowerImageLoaderProtocol, PowerImageResponse } from './PowerImageLoaderProtocol';

export class PowerImageLoader implements PowerImageLoaderProtocol {
  private imageLoaders?: Map<string, PowerImageLoaderProtocol>;
  private static instance: PowerImageLoader;

  private constructor() {
    this.imageLoaders = new Map<string, PowerImageLoaderProtocol>();
  }

  public static getInstance(): PowerImageLoader {
    if (!PowerImageLoader.instance) {
      PowerImageLoader.instance = new PowerImageLoader();
    }
    return PowerImageLoader.instance;
  }

  public registerImageLoader(loader: PowerImageLoaderProtocol, imageType: string) {
    this.imageLoaders!.set(imageType, loader);
  }


  handleRequest(request: PowerImageRequestConfig, response: PowerImageResponse): void {
    const imageLoader: PowerImageLoaderProtocol | undefined = this.imageLoaders!.get(request.imageType!);
    if (imageLoader == undefined) {
      throw new FlutterException('10036', "PowerImageLoader for "
        + request.imageType + " has not been registered.", '');
    }
    imageLoader.handleRequest(request, response);
  }
}
