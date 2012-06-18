//
//  EMRAlertView.h
//  Clara
//
//  Created by Jared Sinclair on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSAlertViewDelegate;

@interface JSAlertView : UIView

typedef enum {
    JSAlertViewDismissalStyleDefault, // Defaults to the global settings set by JSAlertViewPresenter
    JSAlertViewDismissalStyleShrink, 
    JSAlertViewDismissalStyleFall, // Like Tweetbot
    JSAlertViewDismissalStyleExpand, // Like Reeder
    JSAlertViewDismissalStyleFade, // The iOS default looks like this
} JSAlertViewDismissalStyle;

@property (nonatomic, weak) id <JSAlertViewDelegate> delegate;
@property (nonatomic, readonly) int numberOfButtons;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) JSAlertViewDismissalStyle cancelButtonDismissalStyle;
@property (nonatomic, assign) JSAlertViewDismissalStyle acceptButtonDismissalStyle;

+ (void)setGlobalAcceptButtonDismissalAnimationStyle:(JSAlertViewDismissalStyle)style;
+ (void)setGlobalCancelButtonDismissalAnimationStyle:(JSAlertViewDismissalStyle)style;
+ (void)setGlobalTintColor:(UIColor *)tint;
+ (void)resetDefaults;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<JSAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (void)show;
- (void)dismissWithTappedButtonIndex:(NSInteger)index animated:(BOOL)animated;

@end

@protocol JSAlertViewDelegate <NSObject>

@optional
- (void)JS_alertView:(JSAlertView *)alertView tappedButtonAtIndex:(NSInteger)index;
- (void)JS_willPresentAlertView:(JSAlertView *)alertView;
- (void)JS_didPresentAlertView:(JSAlertView *)alertView;
- (void)JS_alertView:(JSAlertView *)alertView willDismissWithButtonIndex:(NSInteger)index;
- (void)JS_alertView:(JSAlertView *)alertView didDismissWithButtonIndex:(NSInteger)index;

@end







