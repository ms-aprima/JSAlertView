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

@property (strong, nonatomic) IBOutlet UIButton *showAlertButton;
@property (strong, nonatomic) UIWindow *overlayWindow;
@property (strong, nonatomic) UILabel *label;
@property (assign, nonatomic) UIDeviceOrientation currentOrientation;

@end

@implementation JSMainViewController

@synthesize showAlertButton;
@synthesize overlayWindow = _overlayWindow;
@synthesize label;
@synthesize currentOrientation;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - JSAlertView & Button

- (IBAction)showAlertView:(id)sender {
    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Title" 
                                                        message:@"Message body goes here." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"One", @"Two", @"Three", nil];
    alertView.delegate = self;
    [alertView show];*/

    JSAlertView *alertView = [[JSAlertView alloc] initWithTitle:@"This is a JSAlertView" 
                                                        message:@"Your message body goes here. You can customize the appearance using the JSAlertViewPresenter singleton class, passing in images and font appearance parameters." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Okay" 
                                              otherButtonTitles:@"One", @"Two", nil];
    [alertView show];
    
    JSAlertView *alertView1 = [[JSAlertView alloc] initWithTitle:@"Stacking Alerts Supported" 
                                                         message:@"Just like UIAlertView, JSAlertView supports stacked alerts." 
                                                        delegate:nil 
                                               cancelButtonTitle:@"I Said Okay" 
                                              otherButtonTitles:nil];
    [alertView1 show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Index %i", buttonIndex);
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    NSLog(@"cancel");
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
