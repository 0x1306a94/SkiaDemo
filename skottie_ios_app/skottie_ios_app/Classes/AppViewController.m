//
//  AppViewController.m
//  skottie_ios_app
//
//  Created by king on 2021/5/26.
//

#import "AppViewController.h"

#import "PreviewViewController.h"

@interface AppViewController ()
@property (nonatomic, strong) NSArray<NSString *> *paths;
@end

@implementation AppViewController

- (void)viewDidLoad {
	[super viewDidLoad];

//	self.title = @"Skia Skottie";
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	self.paths           = [mainBundle pathsForResourcesOfType:@"json" inDirectory:@"data"];

	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.paths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}

	NSString *path      = self.paths[indexPath.row];
	cell.textLabel.text = path.lastPathComponent;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *path      = self.paths[indexPath.row];

	PreviewViewController *vc = [[PreviewViewController alloc] initWithJSONFile:path];
	[self.navigationController pushViewController:vc animated:YES];
}
@end

