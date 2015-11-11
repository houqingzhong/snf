//
//  SNFBaseViewcontroller.m
//  snf
//
//  Created by 调伏自己 on 15/11/11.
//  Copyright © 2015年 调伏自己. All rights reserved.
//

#import "SNFBaseViewcontroller.h"
#import "WTAZoomNavigationController.h"
#import "SNFHeader.h"

@implementation SNFBaseViewcontroller
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setupNavigationItem];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#pragma mark - Instance Methods

- (void)setupNavigationItem
{
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonItemPressed:)];
    [[self navigationItem] setLeftBarButtonItem:menuBarButtonItem];
}

- (void)menuBarButtonItemPressed:(id)sender
{
    [[self wta_zoomNavigationController] revealLeftViewController:YES];
}


@end
