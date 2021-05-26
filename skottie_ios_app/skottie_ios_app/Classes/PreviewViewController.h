//
//  PreviewViewController.h
//  skottie_ios_app
//
//  Created by king on 2021/5/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreviewViewController : UIViewController
- (instancetype)initWithJSONFile:(NSString *)filePath NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END

