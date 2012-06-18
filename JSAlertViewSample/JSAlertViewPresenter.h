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

@property (nonatomic, assign) JSAlertViewDismissalStyle defaultCancelDismissalStyle;
@property (nonatomic, assign) JSAlertViewDismissalStyle defaultAcceptDismissalStyle;
@property (nonatomic, strong) UIColor *defaultColor;

+ (JSAlertViewPresenter *)sharedAlertViewPresenter;
- (void)resetDefaultAppearance;
- (void)showAlertView:(JSAlertView *)alertView;
- (void)JS_alertView:(JSAlertView *)sender tappedButtonAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
