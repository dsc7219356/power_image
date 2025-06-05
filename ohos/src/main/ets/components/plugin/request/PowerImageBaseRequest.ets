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
import { PowerImageDispatcher } from '../dispatcher/PowerImageDispatcher';

import { FlutterMultiFrameImage } from '../loader/FlutterMultiFrameImage';
import { PowerImageLoader } from '../loader/PowerImageLoader';
import { PowerImageResult } from '../loader/PowerImageResult';
import { PowerImageEngineContext } from '../PowerImageEngineContext';
import { PowerImageRequestConfig } from './PowerImageRequestConfig';

export abstract class PowerImageBaseRequest {
  protected static REQUEST_STATE_INITIALIZE_SUCCEED: string = "initializeSucceed";
  protected static REQUEST_STATE_INITIALIZE_FAILED: string = "initializeFailed";
  protected static REQUEST_STATE_LOAD_SUCCEED: string = "loadSucceed";
  protected static REQUEST_STATE_LOAD_FAILED: string = "loadFailed";
  protected static REQUEST_STATE_RELEASE_SUCCEED: string = "releaseSucceed";
  protected static REQUEST_STATE_RELEASE_FAILED: string = "releaseFailed";
  public static RENDER_TYPE_EXTERNAL: string = "external";
  public static RENDER_TYPE_TEXTURE: string = "texture";
  private engineContext: PowerImageEngineContext | undefined = undefined;
  private imageRequestConfig: PowerImageRequestConfig | null = null;
  public requestId: string | undefined = undefined;
  protected imageTaskState: string | undefined = undefined;
  public realResult: PowerImageResult | undefined = undefined;

  constructor(context: PowerImageEngineContext, args: Map<string, Object>) {
    this.engineContext = context;
    this.requestId = args.get("uniqueKey") as string;
    this.imageRequestConfig = PowerImageRequestConfig.requestConfigWithArguments(args);
  }

  public configTask(): boolean {
    const inited: boolean = this.imageRequestConfig != null;
    this.imageTaskState = inited ? PowerImageBaseRequest.REQUEST_STATE_INITIALIZE_SUCCEED
      : PowerImageBaseRequest.REQUEST_STATE_INITIALIZE_FAILED;
    return inited;
  }

  public startLoading(): boolean {
    if (!(PowerImageBaseRequest.REQUEST_STATE_INITIALIZE_SUCCEED === this.imageTaskState)
      && !(PowerImageBaseRequest.REQUEST_STATE_LOAD_FAILED === this.imageTaskState)) {
      // 只有初始化好 或者 加载失败的情况可以重新加载
      return false;
    }
    if (this.imageRequestConfig == null) {
      return false;
    }
    this.performLoadImage();
    return true;
  }

  private performLoadImage() {
    // PowerImageLoader.getInstance().handleRequest(
    //   imageRequestConfig,
    //   new PowerImageLoaderProtocol.PowerImageResponse() {
    //   @Override
    //   public void onResult(PowerImageResult result) {
    //     PowerImageBaseRequest.this.onLoadResult(result);
    //   }
    // }
    // );
    PowerImageLoader.getInstance().handleRequest(this.imageRequestConfig!, (powerImageResult: PowerImageResult) => {
      this.onLoadResult(powerImageResult);
    });
  }

  public onLoadResult(result: PowerImageResult) {
    this.realResult = result;
  }

  public onLoadSuccess() {
    //   PowerImageDispatcher.getInstance().runOnMainThread(new Runnable() {
    //           @Override
    //           public void run() {
    //               PowerImageBaseRequest.this.imageTaskState = REQUEST_STATE_LOAD_SUCCEED;
    //               engineContext.sendImageStateEvent(PowerImageBaseRequest.this.encode(), true);
    //           }
    // });
    PowerImageDispatcher.getInstance().runOnWorkThread(() => {
      this.imageTaskState = PowerImageBaseRequest.REQUEST_STATE_LOAD_SUCCEED;
      this.engineContext!.sendImageStateEvent(this.encode(), true);
    })
  }

  public onLoadFailed(errMsg: string) {
    //   PowerImageDispatcher.getInstance().runOnMainThread(new Runnable() {
    //             @Override
    //             public void run() {
    //                 PowerImageBaseRequest.this.imageTaskState = REQUEST_STATE_LOAD_FAILED;
    //                 Map<String, Object> event = PowerImageBaseRequest.this.encode();
    //                 event.put("errMsg", errMsg != null ? errMsg : "failed!");
    //                 engineContext.sendImageStateEvent(event, false);
    //             }
    // });
    PowerImageDispatcher.getInstance().runOnWorkThread(() => {
      this.imageTaskState = PowerImageBaseRequest.REQUEST_STATE_LOAD_FAILED;
      const event: Map<string, Object> = this.encode();
      event.set("errMsg", errMsg != null ? errMsg : "failed!");
      this.engineContext!.sendImageStateEvent(event, false);
    });
  }

  public stopTask(): boolean {
    return false;
  }

  public encode(): Map<string, Object> {
    const encodedTask: Map<string, Object> = new Map<string, Object>();
    encodedTask.set("uniqueKey", this.requestId!);
    encodedTask.set("state", this.imageTaskState!);
    if (this.realResult != null && this.realResult.success && this.realResult.image instanceof FlutterMultiFrameImage) {
      encodedTask.set("_multiFrame", true);
    }
    return encodedTask;
  }
}