//
//  JSAlertViewPresenter.h
//  JSAlertViewSample
//
//  Created by Jared Sinclair on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSAlertViewConstants.h"

@class JSAlertView;

@interface JSAlertViewPresenter : NSObject

// Pass in resizable UIImages (if you want, there are defaults ready to go)
@property (nonatomic, strong) UIImage *defaultBackgroundImage;
@property (nonatomic, assign) UIEdgeInsets defaultBackgroundEdgeInsets;
@property (nonatomic, strong) UIImage *defaultCancelButtonImage_Normal;
@property (nonatomic, strong) UIImage *defaultCancelButtonImage_Highlighted;
@property (nonatomic, strong) UIImage *defaultAcceptButtonImage_Normal;
@property (nonatomic, strong) UIImage *defaultAcceptButtonImage_Highlighted;

// Follows the conventions of the similarly-named UIAppearance methods available in iOS 5 or later
@property (nonatomic, strong) NSDictionary *defaultTitleTextAttributes;
@property (nonatomic, strong) NSDictionary *defaultMessageTextAttributes;
@property (nonatomic, strong) NSDictionary *defaultCancelButtonTextAttributes;
@property (nonatomic, strong) NSDictionary *defaultAcceptButtonTextAttributes;

@property (nonatomic, assign) JSAlertViewDismissalStyle defaultCancelDismissalStyle;
@property (nonatomic, assign) JSAlertViewDismissalStyle defaultAcceptDismissalStyle;

+ (JSAlertViewPresenter *)sharedAlertViewPresenter;
- (void)resetDefaultAppearance;
- (void)showAlertView:(JSAlertView *)alertView;
- (void)JS_alertView:(JSAlertView *)sender tappedButtonAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
