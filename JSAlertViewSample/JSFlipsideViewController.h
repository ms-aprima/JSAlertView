//
//  JSFlipsideViewController.h
//  JSAlertViewSample
//
//  Created by Jared Sinclair on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSFlipsideViewController;

@protocol JSFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(JSFlipsideViewController *)controller;
@end

@interface JSFlipsideViewController : UIViewController

@property (weak, nonatomic) id <JSFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
