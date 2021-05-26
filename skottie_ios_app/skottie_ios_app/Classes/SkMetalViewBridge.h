// Copyright 2019 Google LLC.
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.
#ifndef SkMetalViewBridge_DEFINED
#define SkMetalViewBridge_DEFINED

#import "include/core/SkTypes.h"

#if (SK_SUPPORT_GPU && defined(SK_METAL) && !defined(SK_BUILD_FOR_GOOGLE3))

#import "GrContextHolder.h"

#import <MetalKit/MetalKit.h>

#import <memory>

class GrRecordingContext;
class SkSurface;
template <typename T>
class sk_sp;

sk_sp<SkSurface> SkMtkViewToSurface(MTKView *, GrRecordingContext *);

GrContextHolder SkMetalDeviceToGrContext(id<MTLDevice>, id<MTLCommandQueue>);

void SkMtkViewConfigForSkia(MTKView *);

#endif

#endif  // SkMetalViewBridge_DEFINED

