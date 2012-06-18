//
//  JSMainViewController.m
//  JSAlertViewSample
//
//  Created by Jared Sinclair on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSMainViewController.h"
#import "JSAlertView.h"
#import "JSAlertViewPresenter.h"

@interface JSMainViewController ()

@property (strong, nonatomic) IBOutlet UIButton *showAlertButton;
@property (strong, nonatomic) UIWindow *overlayWindow;
@property (strong, nonatomic) UILabel *label;
@property (assign, nonatomic) UIDeviceOrientation currentOrientation;
@property (strong, nonatomic) JSAlertView *alertView2;

@end

@implementation JSMainViewController

@synthesize showAlertButton;
@synthesize overlayWindow = _overlayWindow;
@synthesize label;
@synthesize currentOrientation;
@synthesize alertView2;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewDidUnload
{
    [self setShowAlertButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - JSAlertView & Button

- (IBAction)showAlertView:(id)sender {

    JSAlertView *alertView = [[JSAlertView alloc] initWithTitle:@"Turn Off Airplane Mode" 
                                                        message:@"Just like UIAlertView, JSAlertView supports stacked alerts. It also supports."
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"Rate This App", @"Never Ask Again", nil];
    [alertView show];
    
    JSAlertView *alertView1 = [[JSAlertView alloc] initWithTitle:@"Stacking Alerts Supported" 
                                                         message:@"Just like UIAlertView, JSAlertView supports stacked alerts."
                                                        delegate:nil 
                                               cancelButtonTitle:@"Continue" 
                                              otherButtonTitles:nil];
    [alertView1 show];
    
    self.alertView2 = [[JSAlertView alloc] initWithTitle:@"Multiple Animation Types" 
                                                         message:@"JSAlertView has different built-in options for dismissal animations:" 
                                                        delegate:nil 
                                               cancelButtonTitle:@"Default" 
                                               otherButtonTitles:@"Falling", @"Shrinking", @"Expanding", nil];
    self.alertView2.delegate = self;
    [self.alertView2 show];
}

- (void)JS_alertView:(JSAlertView *)alertView tappedButtonAtIndex:(NSInteger)index {
    if (alertView == self.alertView2) {
        NSLog(@"index %i", index);
        switch (index) {
            case 0:
                [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultCancelDismissalStyle:JSAlertViewDismissalStyleFade];
                [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultAcceptDismissalStyle:JSAlertViewDismissalStyleFade];
                break;
            case 1:
                [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultCancelDismissalStyle:JSAlertViewDismissalStyleFall];
                [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultAcceptDismissalStyle:JSAlertViewDismissalStyleFall];
                break;
            case 2:
                [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultCancelDismissalStyle:JSAlertViewDismissalStyleShrink];
                [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultAcceptDismissalStyle:JSAlertViewDismissalStyleShrink];
                break;
            case 3:
                [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultCancelDismissalStyle:JSAlertViewDismissalStyleExpand];
                [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultAcceptDismissalStyle:JSAlertViewDismissalStyleExpand];
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
    
    if ([rootVC shouldAutorotateToInterfaceOrientation:orientation] == NO)
        return;
    
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

- (void)didPresentAlertView:(UIAlertView *)alertView {
    NSLog(@"Alertview.superview = %@", (UIWindow *)(alertView.superview));
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(JSFlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    JSFlipsideViewController *controller = [[JSFlipsideViewController alloc] initWithNibName:@"JSFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}

@end
