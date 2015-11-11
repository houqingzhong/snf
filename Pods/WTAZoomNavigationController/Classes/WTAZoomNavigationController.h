//
//  WTAZoomNavigationController.h
//  WTAZoomNavigationController
//
//  Created by Andrew Carter on 11/13/13.
//  Copyright (c) 2013 Andrew Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTAZoomNavigationController : UIViewController

// Default is 150.0f. Higher == more zooming away, lower == less zooming away
- (instancetype)initWithZoomFactor:(CGFloat)zoomFactor;

- (void)hideLeftViewController:(BOOL)animated;
- (void)revealLeftViewController:(BOOL)animated;
- (void)hideLeftViewController:(BOOL)animated completion:(void (^)())completion;
- (void)revealLeftViewController:(BOOL)animated completion:(void (^)())completion;

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign, getter = isSpringAnimationOn) BOOL springAnimationOn;

@end

@interface UIViewController (WTAZoomNavigationController)

@property (nonatomic, readonly) WTAZoomNavigationController *wta_zoomNavigationController;

@end
