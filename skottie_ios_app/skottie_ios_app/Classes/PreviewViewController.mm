//
//  PreviewViewController.m
//  skottie_ios_app
//
//  Created by king on 2021/5/26.
//

#import "PreviewViewController.h"

#import "SkiaContext.h"
#import "SkottieViewController.h"

#include <cstdlib>

@interface PreviewViewController ()
@property (nonatomic, strong) SkiaContext *skiaContext;
@property (nonatomic, strong) SkottieViewController *skottieController;
@property (nonatomic, strong) __kindof UIView *skiaView;
@property (nonatomic, copy) NSString *filePath;
@end

@implementation PreviewViewController
- (instancetype)initWithJSONFile:(NSString *)filePath {
	if (self == [super init]) {
		self.filePath = filePath;
		[self commonInit];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.view.backgroundColor = UIColor.whiteColor;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self setupSkottieView];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.skottieController setStopAtEnd:NO];
//	self.skiaContext = nil;
//	[self.skiaView removeFromSuperview];
}

- (void)commonInit {
	[self setupSkiaContext];
}

- (void)setupSkiaContext {
	if (!self.skiaContext) {
#if (SK_SUPPORT_GPU && defined(SK_METAL) && !defined(SK_BUILD_FOR_GOOGLE3))
		self.skiaContext = MakeSkiaMetalContext();
#elif (SK_SUPPORT_GPU && defined(SK_GL) && !defined(SK_BUILD_FOR_GOOGLE3))
		self.skiaContext = MakeSkiaGLContext();
#else
		self.skiaContext = MakeSkiaUIContext();
#endif
		if (!self.skiaContext) {
			NSLog(@"abort: failed to make skia context.");
			std::abort();
		}
	}
}

- (void)setupSkottieView {
	if (self.skottieController) {
		return;
	}
	NSData *content = [NSData dataWithContentsOfFile:self.filePath];
	if (!content) {
		NSLog(@"'%@' not found", self.filePath);
		return;
	}

	SkottieViewController *controller = [[SkottieViewController alloc] init];
	if (![controller loadAnimation:content]) {
		return;
	}

	self.skottieController = controller;
	CGFloat screenWidth    = self.view.bounds.size.width;

	CGSize animSize  = [controller size];
	CGFloat height   = animSize.width ? (screenWidth * animSize.height / animSize.width) : 0;
	CGRect frame     = {{0, 0}, {screenWidth, height}};
	UIView *skiaView = [self.skiaContext makeViewWithController:controller withFrame:frame];
	[self.view addSubview:skiaView];
	skiaView.center = self.view.center;

	self.skiaView = skiaView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self.skottieController togglePaused];
	[self.skiaView setNeedsDisplay];
}
@end

