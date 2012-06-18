//
//  JSMainViewController.m
//  JSAlertViewSample
//
//  Created by Jared Sinclair on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSMainViewController.h"
#import "JSAlertView.h"

@interface JSMainViewController ()

@property (strong, nonatomic) IBOutlet UIButton *button_iOSDefault;
@property (strong, nonatomic) IBOutlet UIButton *button_animations;
@property (strong, nonatomic) UIWindow *overlayWindow;
@property (strong, nonatomic) IBOutlet UIButton *button_red;
@property (strong, nonatomic) IBOutlet UIButton *button_green;
@property (strong, nonatomic) IBOutlet UIButton *button_grey;
@property (strong, nonatomic) UILabel *label;
@property (assign, nonatomic) UIDeviceOrientation currentOrientation;
@property (strong, nonatomic) JSAlertView *animationAlertView;

@end

@implementation JSMainViewController

@synthesize button_iOSDefault;
@synthesize button_animations;
@synthesize overlayWindow = _overlayWindow;
@synthesize button_red;
@synthesize button_green;
@synthesize button_grey;
@synthesize label;
@synthesize currentOrientation;
@synthesize animationAlertView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewDidUnload {
    [self setButton_iOSDefault:nil];
    [self setButton_animations:nil];
    [self setButton_red:nil];
    [self setButton_green:nil];
    [self setButton_grey:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - JSAlertView & Button


- (IBAction)buttonPressedDefault:(id)sender {
    JSAlertView *alertView = [[JSAlertView alloc] initWithTitle:@"Mimic iOS Default" 
                                                        message:@"It's easy to mimic the appearance of a vanilla UIAlertView with JSAlertView." 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles: @"Okay", nil];
    [alertView show];
}
- (IBAction)buttonPressedAnimations:(id)sender {
    self.animationAlertView = [[JSAlertView alloc] initWithTitle:@"Different Animations" 
                                                        message:@"There are several options for dismissal animations. These can be set globally, or an alert-by-alert basis." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Default"
                                              otherButtonTitles: @"Falling", @"Shrinking", @"Expanding", nil];
    self.animationAlertView.delegate = self;
    [self.animationAlertView show];
}

- (IBAction)buttonPressedRed:(id)sender {
    JSAlertView *alertView = [[JSAlertView alloc] initWithTitle:@"Supports Custom Colors" 
                                                        message:@"Just pass a UIColor object to a JSAlertView's tintColor property prior to calling 'show'." 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles: @"Okay", nil];
    alertView.tintColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.05 alpha:1.0];
    [alertView show];
}
- (IBAction)buttonPressedGreen:(id)sender {
    JSAlertView *alertView = [[JSAlertView alloc] initWithTitle:@"Supports Custom Colors" 
                                                        message:@"Just pass a UIColor object to a JSAlertView's tintColor property prior to calling 'show'." 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles: @"Okay", nil];
    alertView.tintColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.05 alpha:1.0];
    [alertView show];
}
- (IBAction)buttonPressedGrey:(id)sender {
    JSAlertView *alertView = [[JSAlertView alloc] initWithTitle:@"Supports Custom Colors" 
                                                        message:@"Just pass a UIColor object to a JSAlertView's tintColor property prior to calling 'show'." 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles: @"Okay", nil];
    alertView.tintColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
    [alertView show];
}

- (void)JS_alertView:(JSAlertView *)alertView tappedButtonAtIndex:(NSInteger)index {
    if (alertView == self.animationAlertView) {
        switch (index) {
            case 0:
                [JSAlertView setGlobalAcceptButtonDismissalAnimationStyle:JSAlertViewDismissalStyleDefault];
                [JSAlertView setGlobalCancelButtonDismissalAnimationStyle:JSAlertViewDismissalStyleDefault];
                break;
            case 1:
                [JSAlertView setGlobalAcceptButtonDismissalAnimationStyle:JSAlertViewDismissalStyleFall];
                [JSAlertView setGlobalCancelButtonDismissalAnimationStyle:JSAlertViewDismissalStyleFall];
                break;
            case 2:
                [JSAlertView setGlobalAcceptButtonDismissalAnimationStyle:JSAlertViewDismissalStyleShrink];
                [JSAlertView setGlobalCancelButtonDismissalAnimationStyle:JSAlertViewDismissalStyleShrink];
                break;
            case 3:
                [JSAlertView setGlobalAcceptButtonDismissalAnimationStyle:JSAlertViewDismissalStyleExpand];
                [JSAlertView setGlobalCancelButtonDismissalAnimationStyle:JSAlertViewDismissalStyleExpand];
                break;
            default:
                break;
        }
    }
}

- (void)didRotate:(NSNotification *)notification {
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIViewController *rootVC = mainWindow.rootViewController;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ([rootVC shouldAutorotateToInterfaceOrientation:orientation]) {    
        CGFloat duration = 0.3;
        if ( (UIDeviceOrientationIsLandscape(self.currentOrientation) && UIDeviceOrientationIsLandscape(orientation)) 
            || (UIDeviceOrientationIsPortrait(orientation) && UIDeviceOrientationIsPortrait(self.currentOrientation)) ) {
            duration = 0.6;
        }
        self.currentOrientation = orientation;
        [UIView animateWithDuration:duration animations:^{
            switch (orientation) {
                case UIDeviceOrientationPortrait:
                    label.transform = CGAffineTransformMakeRotation(0);
                    break;
                case UIDeviceOrientationLandscapeLeft:
                    label.transform = CGAffineTransformMakeRotation(M_PI / 2);
                    break;
                case UIDeviceOrientationLandscapeRight:
                    label.transform = CGAffineTransformMakeRotation(M_PI / -2);
                    break; 
                default:
                    break;
            }
        }];
    }
}


@end





