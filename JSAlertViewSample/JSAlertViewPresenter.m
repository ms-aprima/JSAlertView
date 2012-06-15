//
//  JSAlertViewPresenter.m
//  JSAlertViewSample
//
//  Created by Jared Sinclair on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSAlertViewPresenter.h"
#import "JSAlertView.h"

@interface JSAlertViewPresenter ()

@property (nonatomic, strong) NSMutableArray *alertViews;
@property (nonatomic, strong) JSAlertView *visibleAlertView;
@property (nonatomic, strong) UIView *alertContainerView;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@property (nonatomic, strong) UIWindow *alertOverlayWindow;
@property (nonatomic, strong) UIImageView *bgShadow;
@property (nonatomic, assign) BOOL isAnimating;

- (void)dismissAlertViewWithCancelAnimation:(JSAlertView *)alertView;
- (void)dismissAlertViewWithAcceptAnimation:(JSAlertView *)alertView;
- (void)prepareBackgroundShadow;
- (void)prepareAlertContainerView;
- (void)prepareWindow;
- (void)presentAlertView:(JSAlertView *)alertView;
- (void)showNextAlertView;
- (void)hideBackgroundShadow;

@end

@implementation JSAlertViewPresenter

@synthesize defaultBackgroundImage = _defaultBackgroundImage;
@synthesize defaultBackgroundEdgeInsets = _defaultBackgroundEdgeInsets;
@synthesize defaultCancelButtonImage_Normal = _defaultCancelButtonImage_Normal;
@synthesize defaultCancelButtonImage_Highlighted = _defaultCancelButtonImage_Highlighted;
@synthesize defaultAcceptButtonImage_Normal = _defaultAcceptButtonImage_Normal;
@synthesize defaultAcceptButtonImage_Highlighted = _defaultAcceptButtonImage_Highlighted;
@synthesize defaultTitleTextAttributes = _defaultTitleTextAttributes;
@synthesize defaultMessageTextAttributes = _defaultMessageTextAttributes;
@synthesize defaultCancelButtonTextAttributes = _defaultCancelButtonTextAttributes;
@synthesize defaultAcceptButtonTextAttributes = _defaultAcceptButtonTextAttributes;
@synthesize defaultCancelDismissalStyle = _defaultCancelDismissalStyle;
@synthesize defaultAcceptDismissalStyle = _defaultAcceptDismissalStyle;
@synthesize alertViews = _alertViews;
@synthesize visibleAlertView = _visibleAlertView;
@synthesize alertContainerView = _alertContainerView;
@synthesize currentOrientation = _currentOrientation;
@synthesize alertOverlayWindow = _alertOverlayWindow;
@synthesize bgShadow = _bgShadow;
@synthesize isAnimating = _isAnimating;

+ (id)sharedAlertViewPresenter {
    static dispatch_once_t once;
    static JSAlertViewPresenter *sharedAlertViewPresenter;
    dispatch_once(&once, ^ { sharedAlertViewPresenter = [[self alloc] init]; });
    return sharedAlertViewPresenter;
}

- (id)init {
    self = [super init];
    if (self) {
        _alertViews = [NSMutableArray array];
        _currentOrientation = [[UIDevice currentDevice] orientation];
        [self resetDefaultAppearance];
        if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] shouldAutorotateToInterfaceOrientation:_currentOrientation] == NO) {
            if (UIDeviceOrientationIsLandscape(_currentOrientation)) {
                _currentOrientation = UIDeviceOrientationPortrait;
            } else {
                _currentOrientation = UIDeviceOrientationLandscapeRight;
            }
        }
    }
    return self;
}

#pragma mark - Show, Hide, Respond

- (void)showAlertView:(JSAlertView *)alertView {
    [self.alertViews addObject:alertView];
    if (self.visibleAlertView == nil && _isAnimating == NO) {
        [self presentAlertView:alertView];
    }
}

- (void)presentAlertView:(JSAlertView *)alertView {
    _isAnimating = YES;
    self.visibleAlertView = alertView;
    
    if (self.alertOverlayWindow == nil) {
        [self prepareWindow];
    }
    
    if (self.bgShadow == nil) {
        [self prepareBackgroundShadow];
    }
    
    if (self.alertContainerView == nil) {
        [self prepareAlertContainerView];
    }
        
    alertView.transform = CGAffineTransformMakeScale(0.05f, 0.05f);
    alertView.alpha = 0.0f;
    alertView.center = CGPointMake(160.0f, 240.0f);
    [_alertContainerView addSubview:alertView];
    
    [UIView animateWithDuration:0.2f animations:^{
        alertView.alpha = 1.0f;
        _bgShadow.alpha = 0.75f;
    }];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        alertView.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            alertView.transform = CGAffineTransformMakeScale(0.97f, 0.97f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.05f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                alertView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _isAnimating = NO;
            }];
        }];
    }];
}

- (void)showNextAlertView {
    if (self.alertViews.count > 0) {
        [self presentAlertView:[self.alertViews objectAtIndex:0]];
    } 
}

- (void)hideBackgroundShadow {
    [UIView animateWithDuration:0.33f animations:^{
        _bgShadow.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _isAnimating = NO;
        [_bgShadow removeFromSuperview];
        [_alertContainerView removeFromSuperview];
        [_alertOverlayWindow removeFromSuperview];
        self.bgShadow = nil;
        self.alertContainerView = nil;
        self.alertOverlayWindow = nil;
        [(UIWindow *)[[[UIApplication sharedApplication] windows] objectAtIndex:0] makeKeyWindow];
    }];
}

- (void)JS_alertView:(JSAlertView *)sender tappedButtonAtIndex:(NSInteger)index {
    switch (index) {
        case kCancelButtonIndex:
            [self dismissAlertViewWithCancelAnimation:sender];
            break;
        case kAcceptButtonIndex:
            [self dismissAlertViewWithAcceptAnimation:sender];
            break;
        default:
            break;
    }
}

- (void)dismissAlertViewWithCancelAnimation:(JSAlertView *)alertView {
    if (self.alertViews.count == 1) {
        [self hideBackgroundShadow];
    }
    [UIView animateWithDuration:0.33f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        alertView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
        [self.alertViews removeObject:alertView];
        self.visibleAlertView = nil;
        [self showNextAlertView];
    }];
    
}

- (void)dismissAlertViewWithAcceptAnimation:(JSAlertView *)alertView {
    if (self.alertViews.count == 1) {
        [self hideBackgroundShadow];
    }
    [UIView animateWithDuration:0.33f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        alertView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
        [self.alertViews removeObject:alertView];
        self.visibleAlertView = nil;
        [self showNextAlertView];
    }];
}

#pragma mark - Convenience Methods

- (void)prepareWindow {
    self.alertOverlayWindow = [[UIWindow alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] frame]];
    [self.alertOverlayWindow makeKeyAndVisible];
}

- (void)prepareBackgroundShadow {
    self.bgShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alertView_bgShadow.png"]];
    _bgShadow.contentMode = UIViewContentModeCenter;
    _bgShadow.alpha = 0.0f;
    [_alertOverlayWindow addSubview:_bgShadow];
}

- (void)prepareAlertContainerView {
    CGRect bigSquare = _alertOverlayWindow.bounds;
    int longestSideLength = bigSquare.size.width > bigSquare.size.height ? bigSquare.size.width : bigSquare.size.height;
    int xOrigin = _alertOverlayWindow.center.x - longestSideLength / 2;
    int yOrigin = _alertOverlayWindow.center.y - longestSideLength / 2;
    bigSquare = CGRectMake(xOrigin, yOrigin, longestSideLength, longestSideLength);
    self.alertContainerView = [[UIView alloc] initWithFrame:bigSquare];
    [_alertOverlayWindow addSubview:_alertContainerView];
}

- (void)resetDefaultAppearance {
    _defaultBackgroundEdgeInsets = UIEdgeInsetsMake(80, 80, 80, 80);
    _defaultBackgroundImage = [UIImage imageNamed:@"alertView_windowBG.png"];
}

@end










