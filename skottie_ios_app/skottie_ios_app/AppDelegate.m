//
//  AppDelegate.m
//  skottie_ios_app
//
//  Created by king on 2021/5/26.
//

#import "AppDelegate.h"

#import "AppViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
	[[self window] setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[AppViewController alloc] init]]];
	[[self window] makeKeyAndVisible];

	return YES;
}

@end

