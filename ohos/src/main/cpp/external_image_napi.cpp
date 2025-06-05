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

#include "napi/native_api.h"
#include <bits/alltypes.h>
#include <sys/mman.h>
#include <multimedia/image_framework/image_mdk.h>
#include <multimedia/image_framework/image_pixel_map_mdk.h>
#include <native_buffer/native_buffer.h>
#include <native_window/buffer_handle.h>
#include <native_window/external_window.h>
#include <native_image/native_image.h>
#include "hilog/log.h"
#include <map>

#define HILOGF(fmt, ...) (void)OH_LOG_Print(LOG_APP, LOG_ERROR, 0xD001800, "XXXX->", fmt, ##__VA_ARGS__)

std::map<int32_t, NativePixelMap *> maps;

static napi_value NapiGetBitmapPixelsPtr(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    NativePixelMap *pixelMap = OH_PixelMap_InitNativePixelMap(env, args[0]);
    HILOGF("NapiGetBitmapPixelsPtr pixelMap_=%{public}p", pixelMap);

    void *pixelAddr = nullptr;
    int32_t ret = OH_PixelMap_AccessPixels(pixelMap, &pixelAddr);
    if (ret != IMAGE_RESULT_SUCCESS) {
        HILOGF("AccessPixels failed, ret=%{public}d", ret);
    }

    napi_value res;
    int64_t ptrAddr = reinterpret_cast<int64_t>(pixelAddr);
    maps[ptrAddr] = pixelMap;
    napi_create_int64(env, ptrAddr, &res);
    return res;
}

static napi_value NapiReleaseBitmapPixels(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t ptrAddr;
    napi_get_value_int32(env, args[0], &ptrAddr);

    NativePixelMap *pixelMap = maps[ptrAddr];
    HILOGF("NapiReleaseBitmapPixels, pixelMap_=%{public}p", pixelMap);
    if (pixelMap) {
        int32_t ret = OH_PixelMap_UnAccessPixels(pixelMap);
        if (ret != IMAGE_RESULT_SUCCESS) {
            HILOGF("NapiReleaseBitmapPixels, UnAccessPixels failed, ret=%{public}d", ret);
        }
        maps.erase(ptrAddr);
    } else {
        HILOGF("NapiReleaseBitmapPixels, pixelMap is nullptr");
    }
    return nullptr;
}

static napi_value Init(napi_env env, napi_value exports) {
    // 定义暴露在模块上的方法
    napi_property_descriptor desc[] = {
        {"getBitmapPixelsPtr", nullptr, NapiGetBitmapPixelsPtr, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"releaseBitmapPixels", nullptr, NapiReleaseBitmapPixels, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    // 通过此接口开发者可在exports上挂载native方法（即上面的NapiGetBitmapPixelsPtr），exports会通过js引擎绑定到js层的一个js对象
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}

static napi_module nativerenderModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init, // 指定加载对应模块时的回调函数
    .nm_modname =
        "powerimage", // 指定模块名称，对于XComponent相关开发，这个名称必须和ArkTS侧XComponent中libraryname的值保持一致
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterModule(void) {
    // 注册so模块
    napi_module_register(&nativerenderModule);
}