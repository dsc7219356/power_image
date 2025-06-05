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
import { PowerImageEngineContext } from '../PowerImageEngineContext';
import { PowerImageBaseRequest } from './PowerImageBaseRequest';
import { PowerImageExternalRequest } from './PowerImageExternalRequest';
import { PowerImageTextureRequest } from './PowerImageTextureRequest';

export class PowerImageRequestManager {
  private engineContext: PowerImageEngineContext | undefined = undefined;
  private requests: Map<string, PowerImageBaseRequest> | undefined = undefined;

  private textureRegistry: TextureRegistry  | undefined = undefined;

  constructor(context: PowerImageEngineContext) {
    this.engineContext = context;
    this.requests = new  Map<string, PowerImageBaseRequest>();
  }

  public configWithTextureRegistry(textureRegistry: TextureRegistry) {
    this.textureRegistry = textureRegistry;
  }

  public configRequestsWithArguments(list: Array<Map<string, Object>>): Array<Map<string, Object>> {
    let results: Array<Map<string, Object>> = new Array<Map<string, Object>>();
    if (list == null || list.length == 0) {
      return results;
    }
    for (let i = 0; i < list.length; i++) {
      let args: Map<string, Object> = list[i];
      let renderType: string = args.get("renderingType") as string;
      let request: PowerImageBaseRequest;
      if (PowerImageBaseRequest.RENDER_TYPE_EXTERNAL === renderType) {
        request = new PowerImageExternalRequest(this.engineContext!, args);
      } else if (PowerImageBaseRequest.RENDER_TYPE_TEXTURE === renderType) {
        request = new PowerImageTextureRequest(this.engineContext!, args, this.textureRegistry!);
      } else {
        continue;
      }
      this.requests!.set(request!.requestId!, request!);
      let success: boolean = request!.configTask();
      let requestInfo: Map<string, Object> = request!.encode();
      requestInfo.set("success", success);
      results.push(requestInfo);
    }
    return results;
  }

  public startLoadingWithArguments(args: Array<Object>) {
    if (args == null || args.length == 0) {
      return;
    }
    for (let i = 0; i < args.length; i++) {
      const arg: Map<string, Object> = args[i] as Map<string, Object>;
      const requestId: string = arg.get("uniqueKey") as string;
      let request: PowerImageBaseRequest = this.requests!.get(requestId)!;
      request.startLoading();
    }
  }

  public releaseRequestsWithArguments(args: Array<Object>): Array<Map<string, Object>> {
    let results: Array<Map<string, Object>> = new Array<Map<string, Object>>();
    if (args == null || args.length == 0) {
      return results;
    }
    for (let i = 0; i < args.length; i++) {
      const arg: Map<string, Object> = args[i] as Map<string, Object>;
      const requestId: string = arg.get("uniqueKey") as string;
      let request: PowerImageBaseRequest | undefined = this.requests!.get(requestId);
      if (request != undefined || request != null) {
        this.requests!.delete(requestId);
        const success: boolean = request.stopTask();
        const requestInfo: Map<string, Object> = request.encode();
        requestInfo.set("success", success);
        results.push(requestInfo);
      }
    }
    return results;
  }
}