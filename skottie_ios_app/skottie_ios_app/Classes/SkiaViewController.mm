// Copyright 2019 Google LLC.
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

#import "SkiaViewController.h"

#import "include/core/SkCanvas.h"
#import "include/core/SkColor.h"

@implementation SkiaViewController {
}
- (bool)isPaused {
	return false;
}
- (void)togglePaused {
}
- (void)draw:(CGRect)rect toCanvas:(SkCanvas *)canvas atSize:(CGSize)size {
	// Fill with pink.
	canvas->clear(SkColorSetARGB(255, 255, 192, 203));
}
@end

