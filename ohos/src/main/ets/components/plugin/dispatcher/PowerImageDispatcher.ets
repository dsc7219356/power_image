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
import { runningLock } from '@kit.BasicServicesKit';

/**
 * @Description 主要用来处理纹理相关的创建和回收工作
 */
import worker, { MessageEvents } from '@ohos.worker';

export type Runnable = () => void;

export class PowerImageDispatcher {
  // 构造单例对象
  private constructor() {
  }

  private static instance: PowerImageDispatcher;
  private isPrepared: boolean = false;
  //宿主线程
  private workerInstance?: worker.ThreadWorker;

  // private  workLooper?: Looper;

  public static getInstance(): PowerImageDispatcher {
    if (!PowerImageDispatcher.instance) {
      PowerImageDispatcher.instance = new PowerImageDispatcher();

    }
    return PowerImageDispatcher.instance;
  }

  public prepare() {
    if (this.isPrepared) {
      return;
    }
    this.isPrepared = true;
    // this.workerInstance = new worker.ThreadWorker('power_image/ets/components/plugin/workers/PowerImageWorker.ets', {
    //   name: 'com.taobao.power_image.work'
    // });
    // this.workerInstance!.onmessage = (e: MessageEvents) => {
    //   //释放Worker资源
    //   this.workerInstance!.terminate();
    // }
  }

  public runOnWorkThread(runnable?: Runnable): void {
    if (runnable == null || runnable == undefined) {
      return;
    }
    runnable();
    // this.workerInstance!.postMessage(runnable)
  }

  public runOnMainThread(runnable?: Runnable): void {
    if (runnable == null || runnable == undefined) {
      return;
    }
    runnable();
  }

  public runOnMainThreadDelayed(delayMillis: number, runnable?: Runnable): void {
    if (runnable == null || runnable == undefined) {
      return;
    }
    //延迟执行
    setTimeout(() => {
      runnable();
    }, delayMillis);
  }
}