//
//  EMRAlertView.m
//  Clara
//
//  Created by Jared Sinclair on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMRAlertView.h"
#import "RootViewController_iPhone.h"
#import "AppDelegate.h"

@implementation EMRAlertView

@synthesize bgShadow, littleWindowBG, titleLabel, messageLabel, cancelButton;

#define LITTLE_WINDOW_WIDTH 320.0f
#define LITTLE_WINDOW_HEIGHT 280.0f
#define CANCEL_BUTTON_WIDTH 258.0f
#define CANCEL_BUTTON_HEIGHT 56.0f

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle
{
    self = [super init];
    if (self) {
        
        AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        RootViewController_iPhone *rvc = (RootViewController_iPhone *)appDel.rootViewController;
        self.frame = rvc.view.bounds;
        
        self.bgShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alertView_bgShadow.png"]];
        self.bgShadow.contentMode = UIViewContentModeCenter;
        [self addSubview:self.bgShadow];
        
        self.littleWindowBG = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"alertView_windowBG.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(76.0f, 76.0f, 76.0f, 76.0f)]];
        self.littleWindowBG.userInteractionEnabled = YES;
        [self addSubview:self.littleWindowBG];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.frame = CGRectMake(40.0f, 40.0f, LITTLE_WINDOW_WIDTH - 80.0f, 56.0f);
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.textColor = [UIColor colorWithWhite:0.18f alpha:1.0f];
        self.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        self.titleLabel.font = [UIFont fontWithName:MISO_BOLD size:28];
        self.titleLabel.text = title;
        if (title == nil)
            self.titleLabel.text = @"Attention";
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [self.littleWindowBG addSubview:self.titleLabel];
        
        CGSize messageSize = [message sizeWithFont:[UIFont fontWithName:MISO_REGULAR size:26] constrainedToSize:CGSizeMake(LITTLE_WINDOW_WIDTH - 80.0f, 180.0f) lineBreakMode:UILineBreakModeWordWrap];
        
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.frame = CGRectMake(40.0f, 96.0f, LITTLE_WINDOW_WIDTH - 80.0f, messageSize.height + 14.0f);
        self.messageLabel.textAlignment = UITextAlignmentCenter;
        self.messageLabel.numberOfLines = 1000;
        self.messageLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.messageLabel.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
        self.messageLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
        self.messageLabel.font = [UIFont fontWithName:MISO_REGULAR size:26];
        self.messageLabel.text = message;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [self.littleWindowBG addSubview:self.messageLabel];
        
        self.littleWindowBG.frame = CGRectMake(0.0f, (self.bounds.size.height - LITTLE_WINDOW_HEIGHT) / 2.0f, LITTLE_WINDOW_WIDTH, 96.0f + messageSize.height + 28.0f + CANCEL_BUTTON_HEIGHT + 26.0f);
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"alertView_yellowButton_normal.png"] forState:UIControlStateNormal];
        [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"alertView_yellowButton_highlighted.png"] forState:UIControlStateHighlighted];
        [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self.cancelButton setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        self.cancelButton.frame = CGRectMake((LITTLE_WINDOW_WIDTH - CANCEL_BUTTON_WIDTH) / 2.0f, self.littleWindowBG.frame.size.height - CANCEL_BUTTON_HEIGHT - 25.0f, CANCEL_BUTTON_WIDTH, CANCEL_BUTTON_HEIGHT);
        [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        self.cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton.titleLabel.font = [UIFont fontWithName:MISO_BOLD size:28];
        [self.littleWindowBG addSubview:self.cancelButton];
    }    
    
    return self;
}

- (void)show
{
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RootViewController_iPhone *rvc = (RootViewController_iPhone *)appDel.rootViewController;
    [rvc showAlertView:self];
}

- (void)cancelButtonPressed
{
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RootViewController_iPhone *rvc = (RootViewController_iPhone *)appDel.rootViewController;
    [rvc hideAlertView:self];
}

@end










