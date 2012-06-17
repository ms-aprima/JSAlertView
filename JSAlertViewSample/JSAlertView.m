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
@property (strong, nonatomic) NSMutableArray *acceptButtons;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) NSMutableArray *acceptButtonTitles;
@property (assign, nonatomic) CGSize messageSize;
@property (assign, nonatomic) CGSize titleSize;
@property (assign, nonatomic) BOOL isBeingDismissed;

- (void)initialSetup;
- (void)cancelButtonPressed:(id)sender;
- (void)actionButtonPressed:(id)sender;
- (void)prepareBackgroundImage;
- (void)prepareTitle;
- (void)prepareMessage;
- (void)prepareCancelButton;
- (void)prepareAcceptButtons;

@end

@implementation JSAlertView

@synthesize delegate = _delegate;
@synthesize presenter = _presenter;
@synthesize bgShadow = _bgShadow;
@synthesize littleWindowBG = _littleWindowBG;
@synthesize titleLabel = _titleLabel;
@synthesize messageLabel = _messageLabel;
@synthesize cancelButton = _cancelButton;
@synthesize acceptButtons = _acceptButtons;
@synthesize titleText = _titleText;
@synthesize messageText = _messageText;
@synthesize cancelButtonTitle = _cancelButtonTitle;
@synthesize acceptButtonTitles = _acceptButtonTitles;
@synthesize messageSize = _messageSize;
@synthesize titleSize = _titleSize;
@synthesize numberOfButtons;
@synthesize isBeingDismissed = _isBeingDismissed;

#define kMaxViewWidth 284.0f

#define kDefaultTitleFontSize 16
#define kTitleOriginX 14
#define kTitleSpacingMultiplier 1.5
#define kMaxTitleWidth 256
#define kMaxTitleNumberOfLines 3

#define kDefaultMessageFontSize 14
#define kMaxMessageWidth 256.0f
#define kMaxMessageNumberOfLines 8
#define kMessageOriginX 14

#define kSpacing 10
#define kAfterMessageSpaceCorrection 4
#define kSpaceAfterBottomButton 10

#define kLeftButtonOriginX 14
#define kRightButtonOriginX 147
#define kMinButtonWidth 123
#define kMaxButtonWidth 256
#define kButtonHeight 44.0f

#define kWidthForDefaultAlphaBG 268

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<JSAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super init];
    if (self) {
        [self initialSetup];
        _titleText = title && title.length > 0 ? title : @"Untitled Alert";
        _cancelButtonTitle = cancelButtonTitle;
        _acceptButtonTitles = [NSMutableArray array];
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
            [_acceptButtonTitles addObject:arg];
        }
        va_end(args);
        _acceptButtons = [NSMutableArray array];
        _messageText = message;
    }    
    return self;
}

- (int)numberOfButtons {
    int count = 0;
    if (_cancelButton) {
        count += 1;
    }
    count += _acceptButtons.count;
    return count;
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
    [self prepareAcceptButtons];
    CGFloat height = kSpacing * kTitleSpacingMultiplier + _titleSize.height + kSpacing ;
    if (_messageLabel) {
        height += _messageSize.height + kSpacing;
    }
    if (_cancelButton) {
        height += kButtonHeight + kSpacing;
        if (_acceptButtons.count > 1) {
            height += kSpacing;
            height += (kButtonHeight + kSpacing) * _acceptButtonTitles.count;
        }
    } else {
        height += (kButtonHeight + kSpacing) * _acceptButtonTitles.count;
    } 
    height += kSpaceAfterBottomButton;
    self.frame = CGRectMake(0, 0, kMaxViewWidth, height);
    /*UIImageView *dropShadow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"alertView_dropShadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(62, 62, 62, 62)]];
    dropShadow.frame = CGRectMake(-24.0f, -24.0f, kMaxViewWidth + 48, height + 48);
    [self insertSubview:dropShadow atIndex:0];*/
    [_presenter showAlertView:self];
}

- (void)dismissWithTappedButtonIndex:(NSInteger)index animated:(BOOL)animated {
    if (_isBeingDismissed == NO) {
        _isBeingDismissed = YES;
        [_presenter JS_alertView:self tappedButtonAtIndex:index animated:animated];
    }
}

- (void)cancelButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(JS_alertView:tappedButtonAtIndex:)]) {
        [self.delegate JS_alertView:self tappedButtonAtIndex:kCancelButtonIndex];
    }
    if (_isBeingDismissed == NO) {
        _isBeingDismissed = YES;
        [_presenter JS_alertView:self tappedButtonAtIndex:kCancelButtonIndex animated:YES];
    }
}

- (void)actionButtonPressed:(id)sender {
    UIButton *acceptButton = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(JS_alertView:tappedButtonAtIndex:)]) {
        [self.delegate JS_alertView:self tappedButtonAtIndex:acceptButton.tag];
    }
    [_presenter JS_alertView:self tappedButtonAtIndex:acceptButton.tag animated:YES];
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
    /*_littleWindowBG.layer.cornerRadius = 10.0f;
    _littleWindowBG.clipsToBounds = YES;*/
    UIImageView *overlayBorder = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"jsAlertView_defaultBackground_overlay.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40, 40, 40)]];
    overlayBorder.frame = _littleWindowBG.frame;
    overlayBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayBorder.userInteractionEnabled = NO;
    [self addSubview:_littleWindowBG];
    [self addSubview:overlayBorder];
}

- (void)prepareTitle {
    self.titleLabel = [[UILabel alloc] init];
    self.titleSize = [_titleText sizeWithFont:[UIFont boldSystemFontOfSize:kDefaultTitleFontSize] 
                            constrainedToSize:CGSizeMake(kMaxTitleWidth, kDefaultTitleFontSize * kMaxTitleNumberOfLines) 
                                lineBreakMode:UILineBreakModeTailTruncation];
    _titleLabel.frame = CGRectMake(kTitleOriginX, kSpacing * kTitleSpacingMultiplier , kMaxTitleWidth, _titleSize.height);
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
    _titleLabel.text = _titleText;
    _titleLabel.numberOfLines = kMaxTitleNumberOfLines;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [_littleWindowBG addSubview:_titleLabel];
}

- (void)prepareMessage {
    self.messageLabel = [[UILabel alloc] init];
    self.messageSize = [_messageText sizeWithFont:[UIFont boldSystemFontOfSize:kDefaultMessageFontSize] 
                            constrainedToSize:CGSizeMake(kMaxMessageWidth, kMaxMessageNumberOfLines * kDefaultMessageFontSize) 
                                lineBreakMode:UILineBreakModeTailTruncation];
    _messageLabel.frame = CGRectMake(kMessageOriginX, kSpacing * kTitleSpacingMultiplier + _titleSize.height + kSpacing, kMaxMessageWidth, _messageSize.height);
    _messageLabel.textAlignment = UITextAlignmentCenter;
    _messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _messageLabel.font = [UIFont systemFontOfSize:kDefaultMessageFontSize];
    _messageLabel.text = _messageText;
    _messageLabel.numberOfLines = kMaxMessageNumberOfLines;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [_littleWindowBG addSubview:_messageLabel];
}

- (void)prepareCancelButton {
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat yOrigin = kSpacing * kTitleSpacingMultiplier + _titleSize.height + kSpacing;
    if (_messageLabel) {
        yOrigin += _messageSize.height + kSpacing;
    }
    if (_acceptButtonTitles.count > 1) {
        yOrigin += (kButtonHeight + kSpacing) * _acceptButtonTitles.count + kSpacing;
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
    } else if (_acceptButtonTitles.count == 1) {
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMinButtonWidth, kButtonHeight);
    } else {
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
    }
    if (_acceptButtonTitles.count > 0) {
        [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"jsAlertView_iOS_cancelButton_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                                 forState:UIControlStateNormal];
    } else {
        [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"jsAlertView_iOS_okayButton_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                                forState:UIControlStateNormal];
    }
    [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"jsAlertView_iOS_okayCancelButton_highlighted.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                             forState:UIControlStateHighlighted];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.5f] forState:UIControlStateNormal];
    [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    _cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
    [_littleWindowBG addSubview:_cancelButton];
}

- (void)prepareAcceptButtons {
    for (int index = 0; index < _acceptButtonTitles.count; index++) {
        NSString *buttonTitle = [_acceptButtonTitles objectAtIndex:index];
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat yOrigin = kTitleSpacingMultiplier * kSpacing + _titleSize.height + kSpacing;
        if (_messageLabel) {
            yOrigin += _messageSize.height + kSpacing;
        }
        if (_acceptButtonTitles.count > 1) {
            yOrigin += (kButtonHeight + kSpacing) * index;
            acceptButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
        } else if (_cancelButtonTitle) {
            acceptButton.frame = CGRectMake(kRightButtonOriginX, yOrigin, kMinButtonWidth, kButtonHeight);
        } else {
            acceptButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
        }
        [acceptButton setBackgroundImage:[[UIImage imageNamed:@"jsAlertView_iOS_okayButton_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                                 forState:UIControlStateNormal];
        [acceptButton setBackgroundImage:[[UIImage imageNamed:@"jsAlertView_iOS_okayCancelButton_highlighted.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                                 forState:UIControlStateHighlighted];
        [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [acceptButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.5f] forState:UIControlStateNormal];
        [acceptButton setTitle:buttonTitle forState:UIControlStateNormal];
        acceptButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [acceptButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        acceptButton.titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
        [_littleWindowBG addSubview:acceptButton];
        acceptButton.tag = index + 1;
        [_acceptButtons addObject:acceptButton];
    }
}

@end










