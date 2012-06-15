//
//  EMRAlertView.m
//  Clara
//
//  Created by Jared Sinclair on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSAlertView.h"
#import "JSAlertViewPresenter.h"

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

#define LITTLE_WINDOW_WIDTH 320.0f
#define LITTLE_WINDOW_HEIGHT 280.0f
#define CANCEL_BUTTON_WIDTH 258.0f
#define CANCEL_BUTTON_HEIGHT 56.0f

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
    self.littleWindowBG.frame = CGRectMake(0.0f, 0.0f, LITTLE_WINDOW_WIDTH, 96.0f + _messageSize.height + 28.0f + CANCEL_BUTTON_HEIGHT + 26.0f);
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
    self.frame = CGRectMake(0, 0, LITTLE_WINDOW_WIDTH, LITTLE_WINDOW_HEIGHT);
    _presenter = [JSAlertViewPresenter sharedAlertViewPresenter];
}

- (void)prepareBackgroundImage {
    self.littleWindowBG = [[UIImageView alloc] initWithImage:[_presenter.defaultBackgroundImage resizableImageWithCapInsets:_presenter.defaultBackgroundEdgeInsets]];
    self.littleWindowBG.userInteractionEnabled = YES;
    [self addSubview:self.littleWindowBG];
}

- (void)prepareTitle {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake(40.0f, 40.0f, LITTLE_WINDOW_WIDTH - 80.0f, 56.0f);
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.textColor = [UIColor colorWithWhite:0.18f alpha:1.0f];
    self.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.text = _titleText;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.littleWindowBG addSubview:self.titleLabel];
}

- (void)prepareMessage {
    self.messageLabel = [[UILabel alloc] init];
    _messageSize = [_messageText sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(LITTLE_WINDOW_WIDTH - 80.0f, 180.0f) lineBreakMode:UILineBreakModeWordWrap];
    self.messageLabel.frame = CGRectMake(40.0f, 96.0f, LITTLE_WINDOW_WIDTH - 80.0f, _messageSize.height + 14.0f);
    self.messageLabel.textAlignment = UITextAlignmentCenter;
    self.messageLabel.numberOfLines = 1000;
    self.messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.messageLabel.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    self.messageLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.text = _messageText;
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.littleWindowBG addSubview:self.messageLabel];
}

- (void)prepareCancelButton {
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"alertView_yellowButton_normal.png"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"alertView_yellowButton_highlighted.png"] forState:UIControlStateHighlighted];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.cancelButton setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    self.cancelButton.frame = CGRectMake((LITTLE_WINDOW_WIDTH - CANCEL_BUTTON_WIDTH) / 2.0f, self.littleWindowBG.frame.size.height - CANCEL_BUTTON_HEIGHT - 25.0f, CANCEL_BUTTON_WIDTH, CANCEL_BUTTON_HEIGHT);
    [self.cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    self.cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.littleWindowBG addSubview:self.cancelButton];
}

- (void)prepareActionButton {
    
}

@end










