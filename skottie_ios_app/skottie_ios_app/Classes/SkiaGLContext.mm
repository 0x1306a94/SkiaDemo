// Copyright 2020 Google LLC.
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

#import "SkiaContext.h"

#if (SK_SUPPORT_GPU && defined(SK_GL) && !defined(SK_BUILD_FOR_GOOGLE3))

#import "include/core/SkSurface.h"
#import "include/core/SkTime.h"
#import "include/gpu/GrBackendSurface.h"
#import "include/gpu/GrDirectContext.h"
#import "include/gpu/gl/GrGLInterface.h"
#import "include/gpu/gl/GrGLTypes.h"

#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <UIKit/UIKit.h>

#include <CoreFoundation/CoreFoundation.h>

static void configure_glkview_for_skia(GLKView *view) {
	[view setDrawableColorFormat:GLKViewDrawableColorFormatRGBA8888];
	[view setDrawableDepthFormat:GLKViewDrawableDepthFormat24];
	[view setDrawableStencilFormat:GLKViewDrawableStencilFormat8];
}

static sk_sp<SkSurface> make_gl_surface(GrDirectContext *dContext, int width, int height) {
	static constexpr int kStencilBits = 8;
	static constexpr int kSampleCount = 1;
	static const SkSurfaceProps surfaceProps;
	if (!dContext || width <= 0 || height <= 0) {
		return nullptr;
	}
	GLint fboid = 0;
	glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &fboid);
	return SkSurface::MakeFromBackendRenderTarget(
	    dContext,
	    GrBackendRenderTarget(width,
	                          height,
	                          kSampleCount,
	                          kStencilBits,
	                          GrGLFramebufferInfo{(GrGLuint)fboid, GL_RGBA8}),
	    kBottomLeft_GrSurfaceOrigin,
	    kRGBA_8888_SkColorType,
	    nullptr,
	    &surfaceProps);
}

// A UIView that uses a GL-backed SkSurface to draw.
@interface SkiaGLView : GLKView
@property (strong) SkiaViewController *controller;

// Override of the UIView interface.
- (void)drawRect:(CGRect)rect;

// Required initializer.
- (instancetype)initWithFrame:(CGRect)frame
              withEAGLContext:(EAGLContext *)eaglContext
            withDirectContext:(GrDirectContext *)dContext;
@end

@implementation SkiaGLView {
	GrDirectContext *fDContext;
}

- (instancetype)initWithFrame:(CGRect)frame
              withEAGLContext:(EAGLContext *)eaglContext
            withDirectContext:(GrDirectContext *)dContext {
	self      = [super initWithFrame:frame context:eaglContext];
	fDContext = dContext;
	configure_glkview_for_skia(self);
	return self;
}

- (void)drawRect:(CGRect)rect {
	SkiaViewController *viewController = [self controller];
	static constexpr double kFrameRate = 1.0 / 30.0;
	double next                        = [viewController isPaused] ? 0 : kFrameRate + SkTime::GetNSecs() * 1e-9;

	[super drawRect:rect];

	int width  = (int)[self drawableWidth],
	    height = (int)[self drawableHeight];
	if (!(fDContext)) {
		NSLog(@"Error: GrDirectContext missing.\n");
		return;
	}
	if (sk_sp<SkSurface> surface = make_gl_surface(fDContext, width, height)) {
		[viewController draw:rect
		            toCanvas:(surface->getCanvas())
		            atSize:CGSize{(CGFloat)width, (CGFloat)height}];
		surface->flushAndSubmit();
	}
	if (next) {
		[NSTimer scheduledTimerWithTimeInterval:std::max(0.0, next - SkTime::GetNSecs() * 1e-9)
		                                 target:self
		                               selector:@selector(setNeedsDisplay)
		                               userInfo:nil
		                                repeats:NO];
	}
}
@end

@interface SkiaGLContext : SkiaContext
@property (strong) EAGLContext *eaglContext;
- (instancetype)init;
- (UIView *)makeViewWithController:(SkiaViewController *)vc withFrame:(CGRect)frame;
- (SkiaViewController *)getViewController:(UIView *)view;
@end

@implementation SkiaGLContext {
	sk_sp<GrDirectContext> fDContext;
}
- (instancetype)init {
	self = [super init];
	[self setEaglContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3]];
	if (![self eaglContext]) {
		NSLog(@"Falling back to GLES2.\n");
		[self setEaglContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
	}
	if (![self eaglContext]) {
		NSLog(@"[[EAGLContext alloc] initWithAPI:...] failed");
		return nil;
	}
	EAGLContext *oldContext = [EAGLContext currentContext];
	[EAGLContext setCurrentContext:[self eaglContext]];
	fDContext = GrDirectContext::MakeGL(nullptr, GrContextOptions());
	[EAGLContext setCurrentContext:oldContext];
	if (!fDContext) {
		NSLog(@"GrDirectContext::MakeGL failed");
		return nil;
	}
	return self;
}

- (UIView *)makeViewWithController:(SkiaViewController *)vc withFrame:(CGRect)frame {
	SkiaGLView *skiaView = [[SkiaGLView alloc] initWithFrame:frame
	                                         withEAGLContext:[self eaglContext]
	                                       withDirectContext:fDContext.get()];
	[skiaView setController:vc];
	return skiaView;
}
- (SkiaViewController *)getViewController:(UIView *)view {
	return [view isKindOfClass:[SkiaGLView class]] ? [(SkiaGLView *)view controller] : nil;
}
@end

SkiaContext *MakeSkiaGLContext() { return [[SkiaGLContext alloc] init]; }

#endif

