// Copyright 2020 Google LLC.
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.
#ifndef SkiaContext_DEFINED
#define SkiaContext_DEFINED

#import "SkottieViewController.h"

#import <UIKit/UIKit.h>

#import "include/core/SkTypes.h"

@interface SkiaContext : NSObject
- (UIView *)makeViewWithController:(SkiaViewController *)vc withFrame:(CGRect)frame;
- (SkiaViewController *)getViewController:(UIView *)view;
@end

#if (SK_SUPPORT_GPU && defined(SK_METAL) && !defined(SK_BUILD_FOR_GOOGLE3))
SkiaContext *MakeSkiaMetalContext();
#elif (SK_SUPPORT_GPU && defined(SK_GL) && !defined(SK_BUILD_FOR_GOOGLE3))
SkiaContext *MakeSkiaGLContext();
#endif

SkiaContext *MakeSkiaUIContext();
#endif  // SkiaContext_DEFINED

