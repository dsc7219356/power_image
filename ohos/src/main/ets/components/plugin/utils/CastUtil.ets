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
import { Log } from '@ohos/flutter_ohos'

export class CastUtil {
  private constructor() {
  }
  public static get(value: Object, type: string) {
    if (value instanceof Object) {
      
    }
    throw new Error(type + " is required, but value is " + value.constructor.name);
  }

//   public static <T> T get(Object value, Class<T> type) {
  //   if (type.isInstance(value)) {
  //   return type.cast(value);
  // }
  // throw new ClassCastException(type.getName() + " is required, but value is " + value.getClass().getName());
  // }

  public static test() {
    Log.i("TAG", "h");
  }
}