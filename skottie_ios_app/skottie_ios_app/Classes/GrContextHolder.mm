// Copyright 2019 Google LLC.
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

#import "GrContextHolder.h"

#import "include/core/SkTypes.h"

#if SK_SUPPORT_GPU

#import "include/gpu/GrContextOptions.h"
#import "include/gpu/GrDirectContext.h"
#import "include/gpu/gl/GrGLInterface.h"

#ifdef SK_GL
GrContextHolder SkMakeGLContext() {
	return GrContextHolder(GrDirectContext::MakeGL(nullptr, GrContextOptions()).release());
}
#endif

void GrContextRelease::operator()(GrDirectContext *ptr) { SkSafeUnref(ptr); }

#else

void GrContextRelease::operator()(GrDirectContext *) { SkDEBUGFAIL(""); }

#endif

