//
//  EMRAlertView.h
//  Clara
//
//  Created by Jared Sinclair on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRConstants.h"

@interface EMRAlertView : UIView

@property (strong, nonatomic) UIImageView *bgShadow;
@property (strong, nonatomic) UIImageView *littleWindowBG;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *cancelButton;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle;
- (void)show;
- (void)cancelButtonPressed;

@end
