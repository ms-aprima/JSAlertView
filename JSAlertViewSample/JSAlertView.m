//
//  EMRAlertView.m
//  Clara
//
//  Created by Jared Sinclair on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSAlertView.h"
#import "JSAlertViewPresenter.h"
#import <QuartzCore/QuartzCore.h>

@interface JSAlertView ()

@property (weak, nonatomic) JSAlertViewPresenter *presenter;
@property (strong, nonatomic) UIImageView *bgShadow;
@property (strong, nonatomic) UIImageView *littleWindowBG;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *acceptButton;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) NSString *acceptButtonTitle;
@property (assign, nonatomic) CGSize messageSize;
@property (assign, nonatomic) CGSize titleSize;

- (void)initialSetup;
- (void)cancelButtonPressed:(id)sender;
- (void)actionButtonPressed:(id)sender;
- (void)prepareBackgroundImage;
- (void)prepareTitle;
- (void)prepareMessage;
- (void)prepareCancelButton;
- (void)prepareActionButton;

@end

@implementation JSAlertView

@synthesize delegate = _delegate;
@synthesize presenter = _presenter;
@synthesize bgShadow = _bgShadow;
@synthesize littleWindowBG = _littleWindowBG;
@synthesize titleLabel = _titleLabel;
@synthesize messageLabel = _messageLabel;
@synthesize cancelButton = _cancelButton;
@synthesize acceptButton = _acceptButton;
@synthesize titleText = _titleText;
@synthesize messageText = _messageText;
@synthesize cancelButtonTitle = _cancelButtonTitle;
@synthesize acceptButtonTitle = _acceptButtonTitle;
@synthesize messageSize = _messageSize;
@synthesize titleSize = _titleSize;

#define kMaxViewWidth 280.0f

#define kDefaultTitleFontSize 18
#define kTitleOriginX 10
#define kTitleOriginY 10
#define kMaxTitleWidth 250
#define kMaxTitleHeight 54

#define kDefaultMessageFontSize 14
#define kMaxMessageWidth 250.0f
#define kMaxMessageHeight 250.0f
#define kMessageOriginX 10

#define kSpacing 10

#define kLeftButtonOriginX 10
#define kRightButtonOriginX 145
#define kMinButtonWidth 125
#define kMaxButtonWidth 250
#define kButtonHeight 44.0f

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle acceptButtonTitle:(NSString *)acceptButtonTitle {
    self = [super init];
    if (self) {
        [self initialSetup];
        _titleText = title && title.length > 0 ? title : @"Untitled Alert";
        _cancelButtonTitle = cancelButtonTitle && cancelButtonTitle.length > 0 ? cancelButtonTitle : @"Cancel";
        _acceptButtonTitle = acceptButtonTitle && acceptButtonTitle.length > 0 ? acceptButtonTitle : @"Okay";       
        _messageText = message;
    }    
    return self;
}

- (void)show {
    [self prepareBackgroundImage];
    [self prepareTitle];
    if (_messageText && _messageText.length > 0) {
        [self prepareMessage];
    } else {
        _messageSize = CGSizeZero;
    }
    [self prepareCancelButton];
    [self prepareActionButton];
    CGFloat height = kTitleOriginY + _titleSize.height + kSpacing;
    if (_messageLabel) {
        height += _messageSize.height + kSpacing;
    }
    height += kButtonHeight + kSpacing;
    self.frame = CGRectMake(0, 0, kMaxViewWidth, height);
    UIImageView *dropShadow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"alertView_dropShadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(62, 62, 62, 62)]];
    dropShadow.frame = CGRectMake(-24.0f, -24.0f, kMaxViewWidth + 48, height + 48);
    [self insertSubview:dropShadow atIndex:0];
    [_presenter showAlertView:self];
}

- (void)cancelButtonPressed:(id)sender {
    [_presenter JS_alertView:self tappedButtonAtIndex:kCancelButtonIndex];
}

- (void)actionButtonPressed:(id)sender {
    [_presenter JS_alertView:self tappedButtonAtIndex:kAcceptButtonIndex];
}

#pragma mark - Convenience

- (void)initialSetup {
    _presenter = [JSAlertViewPresenter sharedAlertViewPresenter];
    self.frame = CGRectMake(0, 0, kMaxViewWidth, kMaxViewWidth);
    self.backgroundColor = [UIColor clearColor];
}

- (void)prepareBackgroundImage {
    self.littleWindowBG = [[UIImageView alloc] initWithImage:_presenter.defaultBackgroundImage];
    _littleWindowBG.frame = self.frame;
    _littleWindowBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _littleWindowBG.userInteractionEnabled = YES;
    _littleWindowBG.layer.cornerRadius = 10.0f;
    _littleWindowBG.clipsToBounds = YES;
    [self addSubview:_littleWindowBG];
}

- (void)prepareTitle {
    self.titleLabel = [[UILabel alloc] init];
    self.titleSize = [_titleText sizeWithFont:[UIFont boldSystemFontOfSize:kDefaultTitleFontSize] 
                            constrainedToSize:CGSizeMake(kMaxTitleWidth, kMaxTitleHeight) 
                                lineBreakMode:UILineBreakModeMiddleTruncation];
    _titleLabel.frame = CGRectMake(kTitleOriginX, kTitleOriginY, kMaxTitleWidth, _titleSize.height);
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.textColor = [UIColor colorWithWhite:0.18f alpha:1.0f];
    _titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    _titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
    _titleLabel.text = _titleText;
    _titleLabel.numberOfLines = 3;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_littleWindowBG addSubview:_titleLabel];
}

- (void)prepareMessage {
    self.messageLabel = [[UILabel alloc] init];
    self.messageSize = [_messageText sizeWithFont:[UIFont boldSystemFontOfSize:kDefaultMessageFontSize] 
                            constrainedToSize:CGSizeMake(kMaxMessageWidth, kMaxMessageHeight) 
                                lineBreakMode:UILineBreakModeTailTruncation];
    _messageLabel.frame = CGRectMake(kMessageOriginX, kTitleOriginY + _titleSize.height + kSpacing, kMaxMessageWidth, _messageSize.height);
    _messageLabel.textAlignment = UITextAlignmentCenter;
    _messageLabel.numberOfLines = 3;
    _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    _messageLabel.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    _messageLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.text = _messageText;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_littleWindowBG addSubview:_messageLabel];
}

- (void)prepareCancelButton {
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat yOrigin = kTitleOriginX + _titleSize.height + kSpacing;
    if (_messageLabel) {
        yOrigin += _messageSize.height + kSpacing;
    }
    _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"alertView_yellowButton_normal.png"] forState:UIControlStateNormal];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"alertView_yellowButton_highlighted.png"] forState:UIControlStateHighlighted];
    [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_cancelButton setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [_cancelButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    _cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_littleWindowBG addSubview:_cancelButton];
}

- (void)prepareActionButton {
    
}

@end










