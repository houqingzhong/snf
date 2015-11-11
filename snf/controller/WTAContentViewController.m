//
//  WTAContentViewController.m
//  WTAZoomNavigationController
//
//  Created by Andrew Carter on 11/13/13.
//  Copyright (c) 2013 Andrew Carter. All rights reserved.
//

#import "WTAContentViewController.h"
#import "WTAZoomNavigationController.h"
#import "SNFHeader.h"

@interface WTAContentViewController ()

@property (nonatomic, strong) KRVideoPlayerController *player;
@end

@implementation WTAContentViewController

#pragma mark - UIViewController Overrides

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

// For testing
//- (void)willMoveToParentViewController:(UIViewController *)parent
//{
//    [super willMoveToParentViewController:parent];
//    NSLog(@"%@ %@ %@", self, NSStringFromSelector(_cmd), parent);
//}
//
//- (void)didMoveToParentViewController:(UIViewController *)parent
//{
//    [super didMoveToParentViewController:parent];
//    NSLog(@"%@ %@ %@",self, NSStringFromSelector(_cmd), parent);
//}

#pragma mark - Instance Methods

- (void)setupNavigationItem
{
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menuBarButtonItemPressed:)];
    [[self navigationItem] setLeftBarButtonItem:menuBarButtonItem];
}

- (void)menuBarButtonItemPressed:(id)sender
{
    [[self wta_zoomNavigationController] revealLeftViewController:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    

    self.player = [[KRVideoPlayerController alloc] initWithFrame:CGRectMake(0, 20, self.view.width, self.view.width*(9.0/16.0))];
    [self.player setDimissCompleteBlock:^{
        weakSelf.player = nil;
    }];


//    NSString *inputPath = [[NSBundle mainBundle] pathForResource:@"512fa609eade4ccd35fc4df95d9629f0" ofType:@"f4v"];
//    
//    NSString *outputPath = [[NSFileManager defaultManager] pathForPublicFile:@"snf_jkfs.mp4"];
//    NSDictionary *options = @{kFFmpegOutputFormatKey: @"mpegts"};
//    [[FFmpegWrapper new] convertInputPath:inputPath outputPath:outputPath options:options progressBlock:^(NSUInteger bytesRead, uint64_t totalBytesRead, uint64_t totalBytesExpectedToRead) {
//        NSLog(@"%0.2f", (float)totalBytesRead/ totalBytesExpectedToRead);
//    } completionBlock:^(BOOL success, NSError *error) {
//        if (nil == error && success) {
//            NSURL *videoURL = [NSURL URLWithString:outputPath];
//            self.player.contentURL = videoURL;
//            [self.player play];
//
//        }
//    }];

//    NSURL *videoURL = [NSURL URLWithString:outputPath];
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"snf_jkfs" withExtension:@"mp4"];
    self.player.contentURL = videoURL;
    [self.player play];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"001" ofType:@"wav"];
//    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"01" withExtension:@"mp3"];
//    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"512fa609eade4ccd35fc4df95d9629f0" withExtension:@"f4v"];
    [self.player showInWindow];
    
}


@end
