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

#define kMaxViewWidth 280.0f

#define kDefaultTitleFontSize 18
#define kTitleOriginX 10
#define kTitleOriginY 10
#define kMaxTitleWidth 260
#define kMaxTitleNumberOfLines 3

#define kDefaultMessageFontSize 14
#define kMaxMessageWidth 260.0f
#define kMaxMessageNumberOfLines 8
#define kMessageOriginX 10

#define kSpacing 10
#define kAfterMessageSpaceCorrection 4

#define kLeftButtonOriginX 10
#define kRightButtonOriginX 145
#define kMinButtonWidth 125
#define kMaxButtonWidth 260
#define kButtonHeight 44.0f

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
    CGFloat height = kTitleOriginY + _titleSize.height + kSpacing;
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
    UIButton *acceptButton = (UIButton *)sender;
    [_presenter JS_alertView:self tappedButtonAtIndex:acceptButton.tag];
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
                            constrainedToSize:CGSizeMake(kMaxTitleWidth, kDefaultTitleFontSize * kMaxTitleNumberOfLines) 
                                lineBreakMode:UILineBreakModeTailTruncation];
    _titleLabel.frame = CGRectMake(kTitleOriginX, kTitleOriginY, kMaxTitleWidth, _titleSize.height);
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _titleLabel.textColor = [UIColor colorWithWhite:0.18f alpha:1.0f];
    _titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
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
                            constrainedToSize:CGSizeMake(kMaxMessageWidth, kMaxMessageNumberOfLines * kDefaultMessageFontSize) 
                                lineBreakMode:UILineBreakModeTailTruncation];
    _messageLabel.frame = CGRectMake(kMessageOriginX, kTitleOriginY + _titleSize.height + kSpacing, kMaxMessageWidth, _messageSize.height);
    _messageLabel.textAlignment = UITextAlignmentCenter;
    _messageLabel.numberOfLines = kMaxMessageNumberOfLines;
    _messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _messageLabel.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    _messageLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    _messageLabel.font = [UIFont systemFontOfSize:kDefaultMessageFontSize];
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
    if (_acceptButtonTitles.count > 1) {
        yOrigin += (kButtonHeight + kSpacing) * _acceptButtonTitles.count + kSpacing;
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
    } else if (_acceptButtonTitles.count == 1) {
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMinButtonWidth, kButtonHeight);
    } else {
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
    }
    [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"general_blueButton_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 10, 1, 10)]
                             forState:UIControlStateNormal];
    [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"general_blueButton_highlighted.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(2, 10, 1, 10)]
                             forState:UIControlStateHighlighted];
    [_cancelButton setTitleColor:[UIColor colorWithRed:0.0f green:0.33f blue:0.50f alpha:1.0f] forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithRed:0.0f green:0.33f blue:0.50f alpha:1.0f] forState:UIControlStateHighlighted];
    [_cancelButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateNormal];
    [_cancelButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    _cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
    [_littleWindowBG addSubview:_cancelButton];
}

- (void)prepareAcceptButtons {
    for (int index = 0; index < _acceptButtonTitles.count; index++) {
        NSString *buttonTitle = [_acceptButtonTitles objectAtIndex:index];
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat yOrigin = kTitleOriginX + _titleSize.height + kSpacing;
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
        [acceptButton setBackgroundImage:[[UIImage imageNamed:@"general_blueButton_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 10, 1, 10)]
                                 forState:UIControlStateNormal];
        [acceptButton setBackgroundImage:[[UIImage imageNamed:@"general_blueButton_highlighted.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(2, 10, 1, 10)]
                                 forState:UIControlStateHighlighted];
        [acceptButton setTitleColor:[UIColor colorWithRed:0.0f green:0.33f blue:0.50f alpha:1.0f] forState:UIControlStateNormal];
        [acceptButton setTitleColor:[UIColor colorWithRed:0.0f green:0.33f blue:0.50f alpha:1.0f] forState:UIControlStateHighlighted];
        [acceptButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateNormal];
        [acceptButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
        [acceptButton setTitle:buttonTitle forState:UIControlStateNormal];
        acceptButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [acceptButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        acceptButton.titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
        [_littleWindowBG addSubview:acceptButton];
        acceptButton.tag = index + 1;
        [_acceptButtons addObject:acceptButton];
    }
}

@end










