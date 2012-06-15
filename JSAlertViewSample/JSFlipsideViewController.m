//
//  JSFlipsideViewController.m
//  JSAlertViewSample
//
//  Created by Jared Sinclair on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSFlipsideViewController.h"

@interface JSFlipsideViewController ()

@end

@implementation JSFlipsideViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
