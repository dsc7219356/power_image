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

import { EventChannel, FlutterException, MethodCall, TextureRegistry } from '@ohos/flutter_ohos';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { PowerImageRequestManager } from './request/PowerImageRequestManager';

export class PowerImageEngineContext implements MethodCallHandler {
  private powerImageRequestManager: PowerImageRequestManager | undefined = undefined;
  private powerImageEventSink: PowerImageEventSink | undefined = undefined;
  /// The MethodChannel that will the communication between Flutter and native OHOS
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private channel: MethodChannel | null = null;
  private eventChannel: EventChannel | null = null;

  constructor() {
    this.powerImageRequestManager = new PowerImageRequestManager(this);
    this.powerImageEventSink = new PowerImageEventSink();
  }


  public onAttachedToEngine(binding: FlutterPluginBinding) {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "power_image/method");
    this.channel.setMethodCallHandler(this);
    this.eventChannel = new EventChannel(
      binding.getBinaryMessenger(), "power_image/event");
    this.eventChannel.setStreamHandler(this.powerImageEventSink);

    this.configWithTextureRegistry(binding.getTextureRegistry());
  }

  public configWithTextureRegistry(textureRegistry: TextureRegistry) {
    this.powerImageRequestManager!.configWithTextureRegistry(textureRegistry);
  }

  public configRequestsWithArguments(list: Array<Map<string, Object>>): Array<Map<string, Object>> {
    return this.powerImageRequestManager!.configRequestsWithArguments(list);
  }

  public startLoadingWithArguments(args: Array<Object>) {
    this.powerImageRequestManager!.startLoadingWithArguments(args);
  }

  public releaseRequestsWithArguments(argument: Array<Object>): Array<Map<string, Object>> {
    return this.powerImageRequestManager!.releaseRequestsWithArguments(argument);
  }

  public sendImageStateEvent(event: Map<string, Object>, success: boolean) {
    if (this.powerImageEventSink != null || this.powerImageEventSink != undefined) {
      this.powerImageEventSink.sendImageStateEvent(event, success);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "startImageRequests") {
      if (call.args instanceof Array) {
        const args: Array<Map<string, Object>> = call.args as Array<Map<string, Object>>;
        const results: Array<Object> = this.configRequestsWithArguments(args);
        result.success(results);
        // 开始图片加载任务
        this.startLoadingWithArguments(args);
      } else {
        throw new Error('startImageRequests require List arguments');
      }
    } else if (call.method == "releaseImageRequests") {
      if (call.args instanceof Array) {
        const args: Array<Map<string, Object>> = call.args as Array<Map<string, Object>>;
        const results: Array<Object> = this.releaseRequestsWithArguments(args);
        result.success(results);
      } else {
        throw new Error('stopImageRequests require List arguments');
      }
    } else {
      result.notImplemented()
    }
  }

  public onDetached() {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
    if (this.eventChannel != null) {
      this.eventChannel.setStreamHandler(null);
    }
  }
}

class PowerImageEventSink implements StreamHandler {
  private eventSink: EventSink | null = null;

  onListen(args: Object, events: EventSink): void {
    this.eventSink = events;
  }

  onCancel(args: Object): void {
    this.eventSink = null;
  }

  public sendImageStateEvent(event: Map<string, Object>, success: boolean) {
    if (this.eventSink == null || event == null) {
      return;
    }
    event.set("eventName", "onReceiveImageEvent");
    event.set("success", success);
    this.eventSink.success(event);
  }
}

