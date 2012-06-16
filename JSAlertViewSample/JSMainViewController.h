//
//  JSMainViewController.h
//  JSAlertViewSample
//
//  Created by Jared Sinclair on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSFlipsideViewController.h"
#import "JSAlertView.h"

@interface JSMainViewController : UIViewController <JSFlipsideViewControllerDelegate, UIAlertViewDelegate, JSAlertViewDelegate>

- (IBAction)showInfo:(id)sender;

@end
