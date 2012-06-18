//
//  EMRAlertView.m
//  Clara
//
//  Created by Jared Sinclair on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSAlertView.h"
#import <QuartzCore/QuartzCore.h>

@interface UIImage (IPImageUtils)

+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color;
+ (UIImage*)imageFromMainBundleFile:(NSString*)aFileName;

@end

@implementation UIImage (IPImageUtils)

+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color {
	UIImage *image = [UIImage imageFromMainBundleFile:name];
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
	CGContextRef c = UIGraphicsGetCurrentContext();
	[image drawInRect:rect];
	CGContextSetFillColorWithColor(c, [color CGColor]);
	CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
	CGContextFillRect(c, rect);
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	return result;
}

+ (UIImage*)imageFromMainBundleFile:(NSString*)aFileName; {
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath,aFileName]];
}

@end

@interface JSAlertViewPresenter : NSObject

@property (nonatomic, assign) JSAlertViewDismissalStyle defaultCancelDismissalStyle;
@property (nonatomic, assign) JSAlertViewDismissalStyle defaultAcceptDismissalStyle;
@property (nonatomic, strong) UIColor *defaultColor;

+ (JSAlertViewPresenter *)sharedAlertViewPresenter;
- (void)resetDefaultAppearance;
- (void)showAlertView:(JSAlertView *)alertView;
- (void)JS_alertView:(JSAlertView *)sender tappedButtonAtIndex:(NSInteger)index animated:(BOOL)animated;

@end

@interface JSAlertViewPresenter ()

@property (nonatomic, strong) NSMutableArray *alertViews;
@property (nonatomic, strong) JSAlertView *visibleAlertView;
@property (nonatomic, strong) UIView *alertContainerView;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@property (nonatomic, strong) UIWindow *alertOverlayWindow;
@property (nonatomic, strong) UIWindow *originalKeyWindow;
@property (nonatomic, strong) UIImageView *bgShadow;
@property (nonatomic, assign) BOOL isAnimating;

- (void)dismissAlertView:(JSAlertView *)alertView withCancelAnimation:(BOOL)animated atButtonIndex:(NSInteger)index;
- (void)dismissAlertView:(JSAlertView *)alertView withAcceptAnimation:(BOOL)animated atButtonIndex:(NSInteger)index;

- (void)dismissAlertView:(JSAlertView *)alertView withShrinkAnimation:(BOOL)animated atButtonIndex:(NSInteger)index;
- (void)dismissAlertView:(JSAlertView *)alertView withFallAnimation:(BOOL)animated atButtonIndex:(NSInteger)index;
- (void)dismissAlertView:(JSAlertView *)alertView withExpandAnimation:(BOOL)animated atButtonIndex:(NSInteger)index;
- (void)dismissAlertView:(JSAlertView *)alertView withFadeAnimation:(BOOL)animated atButtonIndex:(NSInteger)index;

- (void)prepareBackgroundShadow;
- (void)prepareAlertContainerView;
- (void)prepareWindow;
- (void)presentAlertView:(JSAlertView *)alertView;
- (void)showNextAlertView;
- (void)dismissWindow;
- (void)updateViewForOrientation:(UIDeviceOrientation)orientation animated:(BOOL)animated;

@end

@implementation JSAlertViewPresenter

@synthesize defaultCancelDismissalStyle = _defaultCancelDismissalStyle;
@synthesize defaultAcceptDismissalStyle = _defaultAcceptDismissalStyle;
@synthesize alertViews = _alertViews;
@synthesize visibleAlertView = _visibleAlertView;
@synthesize alertContainerView = _alertContainerView;
@synthesize currentOrientation = _currentOrientation;
@synthesize alertOverlayWindow = _alertOverlayWindow;
@synthesize bgShadow = _bgShadow;
@synthesize isAnimating = _isAnimating;
@synthesize defaultColor = _defaultColor;
@synthesize originalKeyWindow = _originalKeyWindow;

#define kCancelButtonIndex 0

+ (id)sharedAlertViewPresenter {
    static dispatch_once_t once;
    static JSAlertViewPresenter *sharedAlertViewPresenter;
    dispatch_once(&once, ^ { sharedAlertViewPresenter = [[self alloc] init]; });
    return sharedAlertViewPresenter;
}

- (id)init {
    self = [super init];
    if (self) {
        NSAssert([[[UIApplication sharedApplication] keyWindow] rootViewController], @"JSAlertView requires that your application's keyWindow has a rootViewController");
        _alertViews = [NSMutableArray array];
        [self resetDefaultAppearance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    return self;
}

#pragma mark - Rotation

- (void)didRotate:(NSNotification *)notification {
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIViewController *rootVC = mainWindow.rootViewController;
    UIViewController *currentViewController = rootVC;
    if (rootVC.presentedViewController) {
        currentViewController = rootVC.presentedViewController;
    }
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ([currentViewController shouldAutorotateToInterfaceOrientation:orientation]) {    
        [self updateViewForOrientation:orientation animated:YES];
    }
}

- (void)updateViewForOrientation:(UIDeviceOrientation)orientation animated:(BOOL)animated {
    CGFloat duration = 0.0f;
    if (animated) {
        duration = 0.3;
        if ( (UIDeviceOrientationIsLandscape(self.currentOrientation) && UIDeviceOrientationIsLandscape(orientation)) 
            || (UIDeviceOrientationIsPortrait(orientation) && UIDeviceOrientationIsPortrait(self.currentOrientation)) ) {
            duration = 0.6;
        }
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            duration = duration * 1.3;
        }
    }
    self.currentOrientation = orientation;
    [UIView animateWithDuration:duration animations:^{
        switch (orientation) {
            case UIDeviceOrientationPortrait:
                _alertContainerView.transform = CGAffineTransformMakeRotation(0);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                _alertContainerView.transform = CGAffineTransformMakeRotation(M_PI);
                break;
            case UIDeviceOrientationLandscapeLeft:
                _alertContainerView.transform = CGAffineTransformMakeRotation(M_PI / 2);
                break;
            case UIDeviceOrientationLandscapeRight:
                _alertContainerView.transform = CGAffineTransformMakeRotation(M_PI / -2);
                break; 
            default:
                break;
        }
    }];

}

#pragma mark - Show, Hide, Respond

- (void)showAlertView:(JSAlertView *)alertView {
    [self.alertViews addObject:alertView];
    if (self.visibleAlertView == nil && _isAnimating == NO) {
        [self presentAlertView:alertView];
    }
}

- (void)presentAlertView:(JSAlertView *)alertView {
    _isAnimating = YES;
    self.visibleAlertView = alertView;
    
    if ([alertView.delegate respondsToSelector:@selector(JS_willPresentAlertView:)]) {
        [alertView.delegate JS_willPresentAlertView:alertView];
    }
    
    if (self.alertOverlayWindow == nil) {
        [self prepareWindow];
    }
    
    if (self.bgShadow == nil) {
        [self prepareBackgroundShadow];
    }
    
    if (self.alertContainerView == nil) {
        [self prepareAlertContainerView];
    }
    
    alertView.transform = CGAffineTransformMakeScale(0.05f, 0.05f);
    alertView.alpha = 0.0f;
    alertView.center = CGPointMake(floorf(_alertContainerView.center.x), floorf(_alertContainerView.center.y));
    [_alertContainerView addSubview:alertView];
    
    [UIView animateWithDuration:0.2f animations:^{
        alertView.alpha = 1.0f;
        _bgShadow.alpha = 1.0f;
    }];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        alertView.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            alertView.transform = CGAffineTransformMakeScale(0.97f, 0.97f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.05f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                alertView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _isAnimating = NO;
                if ([alertView.delegate respondsToSelector:@selector(JS_didPresentAlertView:)]) {
                    [alertView.delegate JS_didPresentAlertView:alertView];
                }
            }];
        }];
    }];
}

- (void)showNextAlertView {
    if (self.alertViews.count > 0) {
        [self presentAlertView:[self.alertViews objectAtIndex:0]];
    } 
}

- (void)dismissWindow {
    [UIView animateWithDuration:0.33f animations:^{
        _bgShadow.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _isAnimating = NO;
        [_bgShadow removeFromSuperview];
        [_alertContainerView removeFromSuperview];
        [_alertOverlayWindow removeFromSuperview];
        self.bgShadow = nil;
        self.alertContainerView = nil;
        self.alertOverlayWindow = nil;
        [self.originalKeyWindow makeKeyAndVisible];
        self.originalKeyWindow = nil;
    }];
}

- (void)JS_alertView:(JSAlertView *)sender tappedButtonAtIndex:(NSInteger)index animated:(BOOL)animated {
    if ([sender.delegate respondsToSelector:@selector(JS_alertView:willDismissWithButtonIndex:)]) {
        [sender.delegate JS_alertView:sender willDismissWithButtonIndex:index];
    }
    if (index == kCancelButtonIndex) {      
        if (sender.numberOfButtons > 1) {
            [self dismissAlertView:sender withCancelAnimation:animated atButtonIndex:index];
        } else {
            [self dismissAlertView:sender withAcceptAnimation:animated atButtonIndex:index];
        }
    } else {
        [self dismissAlertView:sender withAcceptAnimation:animated atButtonIndex:index];
    }
}

- (void)dismissAlertView:(JSAlertView *)alertView withCancelAnimation:(BOOL)animated atButtonIndex:(NSInteger)index {
    if (self.alertViews.count == 1) {
        [self dismissWindow];
    }
    switch (self.defaultCancelDismissalStyle) {
        case JSAlertViewDismissalStyleShrink:
            [self dismissAlertView:alertView withShrinkAnimation:animated atButtonIndex:index];
            break;
        case JSAlertViewDismissalStyleFall:
            [self dismissAlertView:alertView withFallAnimation:animated atButtonIndex:index];
            break;
        case JSAlertViewDismissalStyleExpand:
            [self dismissAlertView:alertView withExpandAnimation:animated atButtonIndex:index];
            break;
        case JSAlertViewDismissalStyleFade:
        case JSAlertViewDismissalStyleDefault:
            [self dismissAlertView:alertView withFadeAnimation:animated atButtonIndex:index];
            break;
        default:
            break;
    }    
}

- (void)dismissAlertView:(JSAlertView *)alertView withAcceptAnimation:(BOOL)animated atButtonIndex:(NSInteger)index {
    if (self.alertViews.count == 1) {
        [self dismissWindow];
    }
    switch (self.defaultAcceptDismissalStyle) {
        case JSAlertViewDismissalStyleShrink:
            [self dismissAlertView:alertView withShrinkAnimation:animated atButtonIndex:index];
            break;
        case JSAlertViewDismissalStyleFall:
            [self dismissAlertView:alertView withFallAnimation:animated atButtonIndex:index];
            break;
        case JSAlertViewDismissalStyleExpand:
            [self dismissAlertView:alertView withExpandAnimation:animated atButtonIndex:index];
            break;
        case JSAlertViewDismissalStyleFade:
        case JSAlertViewDismissalStyleDefault:
            [self dismissAlertView:alertView withFadeAnimation:animated atButtonIndex:index];
            break;
        default:
            break;
    }
}

- (void)dismissAlertView:(JSAlertView *)alertView withShrinkAnimation:(BOOL)animated atButtonIndex:(NSInteger)index {
    CGFloat duration = 0.0f;
    if (animated) {
        duration = 0.2f;
    }
    __weak UIView *blockSafeAlertView = alertView;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        blockSafeAlertView.alpha = 0.0f;
        blockSafeAlertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [blockSafeAlertView removeFromSuperview];
        [self.alertViews removeObject:blockSafeAlertView];
        self.visibleAlertView = nil;
        if ([alertView.delegate respondsToSelector:@selector(JS_alertView:didDismissWithButtonIndex:)]) {
            [alertView.delegate JS_alertView:alertView didDismissWithButtonIndex:index];
        }
        [self showNextAlertView];
    }];
}

- (void)dismissAlertView:(JSAlertView *)alertView withFallAnimation:(BOOL)animated atButtonIndex:(NSInteger)index {
    CGFloat duration = 0.0f;
    if (animated) {
        duration = 0.3f;
    }
    __weak UIView *blockSafeAlertView = alertView;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        blockSafeAlertView.alpha = 0.0f;
        CGRect frame = blockSafeAlertView.frame;
        frame.origin.y += 320.0f;
        blockSafeAlertView.frame = frame;
        blockSafeAlertView.transform = CGAffineTransformMakeRotation(M_PI / -3.5);
    } completion:^(BOOL finished) {
        [blockSafeAlertView removeFromSuperview];
        [self.alertViews removeObject:blockSafeAlertView];
        self.visibleAlertView = nil;
        if ([alertView.delegate respondsToSelector:@selector(JS_alertView:didDismissWithButtonIndex:)]) {
            [alertView.delegate JS_alertView:alertView didDismissWithButtonIndex:index];
        }
        [self showNextAlertView];
    }];
}

- (void)dismissAlertView:(JSAlertView *)alertView withExpandAnimation:(BOOL)animated atButtonIndex:(NSInteger)index {
    CGFloat duration = 0.0f;
    if (animated) {
        duration = 0.25f;
    }
    __weak UIView *blockSafeAlertView = alertView;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        blockSafeAlertView.alpha = 0.0f;
        blockSafeAlertView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [blockSafeAlertView removeFromSuperview];
        [self.alertViews removeObject:blockSafeAlertView];
        self.visibleAlertView = nil;
        if ([alertView.delegate respondsToSelector:@selector(JS_alertView:didDismissWithButtonIndex:)]) {
            [alertView.delegate JS_alertView:alertView didDismissWithButtonIndex:index];
        }
        [self showNextAlertView];
    }];
}

- (void)dismissAlertView:(JSAlertView *)alertView withFadeAnimation:(BOOL)animated atButtonIndex:(NSInteger)index {
    CGFloat duration = 0.0f;
    if (animated) {
        duration = 0.25f;
    }
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        alertView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
        [self.alertViews removeObject:alertView];
        self.visibleAlertView = nil;
        if ([alertView.delegate respondsToSelector:@selector(JS_alertView:didDismissWithButtonIndex:)]) {
            [alertView.delegate JS_alertView:alertView didDismissWithButtonIndex:index];
        }
        [self showNextAlertView];
    }];
}

#pragma mark - Convenience Methods

- (void)prepareWindow {
    self.originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
    self.alertOverlayWindow = [[UIWindow alloc] initWithFrame:[self.originalKeyWindow frame]];
    _alertOverlayWindow.windowLevel = UIWindowLevelAlert;
    _alertOverlayWindow.backgroundColor = [UIColor clearColor];
    [self.alertOverlayWindow makeKeyAndVisible];
}

- (void)prepareBackgroundShadow {
    UIImage *shadowImage = [UIImage imageFromMainBundleFile:@"jsAlertView_gradientShadowOverlay_iPhone.png"]; // Used to use separate images for each device. This one looks great by itself.
    self.bgShadow = [[UIImageView alloc] initWithImage:shadowImage];
    _bgShadow.frame = [[UIScreen mainScreen] bounds];
    _bgShadow.contentMode = UIViewContentModeScaleToFill;
    _bgShadow.center = _alertOverlayWindow.center;
    _bgShadow.alpha = 0.0f;
    [_alertOverlayWindow addSubview:_bgShadow];
}

- (void)prepareAlertContainerView {
    self.alertContainerView = [[UIView alloc] initWithFrame:_alertOverlayWindow.bounds];
    _alertContainerView.clipsToBounds = NO;
    [_alertOverlayWindow addSubview:_alertContainerView];
    _currentOrientation = [[UIDevice currentDevice] orientation];
    UIViewController *currentViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if (currentViewController.presentedViewController) {
        currentViewController = currentViewController.presentedViewController;
    }
    if (_currentOrientation == UIDeviceOrientationUnknown) {
        _currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    }
    if ([currentViewController shouldAutorotateToInterfaceOrientation:_currentOrientation] == NO) {
        if (UIDeviceOrientationIsLandscape(_currentOrientation)) {
            _currentOrientation = _currentOrientation == UIDeviceOrientationLandscapeRight ? UIDeviceOrientationLandscapeRight : UIDeviceOrientationLandscapeLeft;
        } else {
            _currentOrientation = _currentOrientation == UIDeviceOrientationPortrait ? UIDeviceOrientationPortrait : UIDeviceOrientationPortraitUpsideDown;
        }
    }
    [self updateViewForOrientation:_currentOrientation animated:NO];
}

- (void)resetDefaultAppearance {
    _defaultCancelDismissalStyle = JSAlertViewDismissalStyleFade;
    _defaultAcceptDismissalStyle = JSAlertViewDismissalStyleFade;
    _defaultColor = [UIColor colorWithRed:0.02f green:0.06f blue:0.25f alpha:1.0f];
}

@end

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
- (UIImage *)defaultBackgroundImage;

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
@synthesize tintColor = _tintColor;
@synthesize cancelButtonDismissalStyle = _cancelButtonDismissalStyle;
@synthesize acceptButtonDismissalStyle = _acceptButtonDismissalStyle;

#define kMaxViewWidth 284.0f

#define kDefaultTitleFontSize 18
#define kTitleOriginX 20
#define kTitleLeadingTop 19
#define kTitleLeadingBottom 10
#define kTitleSpacingMultiplier 1.5
#define kMaxTitleWidth 244
#define kMaxTitleNumberOfLines 3

#define kDefaultMessageFontSize 16
#define kMaxMessageWidth 256.0f
#define kMaxMessageNumberOfLines 8
#define kMessageOriginX 14

#define kSpacing 7
#define kSpaceAboveTopButton 7
#define kSpaceAfterOneOfSeveralActionButtons 6
#define kSpaceAboveSeparatedCancelButton 7
#define kSpaceAfterBottomButton 15
#define kMinimumButtonLabelSize 12
#define kLeftButtonOriginX 11
#define kRightButtonOriginX 146
#define kMinButtonWidth 127
#define kMaxButtonWidth 262
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
            if (arg.length > 0) {
                [_acceptButtonTitles addObject:arg];
            }
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
    if (_cancelButtonTitle && _cancelButtonTitle.length > 0) {
        [self prepareCancelButton];
    }
    [self prepareAcceptButtons];
    CGFloat height = kTitleLeadingTop + _titleSize.height + kTitleLeadingBottom ;
    if (_messageLabel) {
        height += _messageSize.height + kSpacing;
    }
    height += kSpaceAboveTopButton;
    if (_cancelButton) {
        height += kButtonHeight + kSpaceAfterBottomButton;
        if (_acceptButtons.count > 1) {
            height += (kButtonHeight + kSpaceAfterOneOfSeveralActionButtons) * _acceptButtonTitles.count + kSpaceAboveSeparatedCancelButton + kSpacing;
        }
    } else {
        height += (kButtonHeight + kSpaceAfterOneOfSeveralActionButtons) * _acceptButtonTitles.count - kSpaceAfterOneOfSeveralActionButtons + kSpaceAfterBottomButton;
    } 
    self.frame = CGRectMake(0, 0, kMaxViewWidth, height);
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
    self.littleWindowBG = [[UIImageView alloc] initWithImage:[self defaultBackgroundImage]];
    _littleWindowBG.frame = self.frame;
    _littleWindowBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _littleWindowBG.userInteractionEnabled = YES;
    UIImageView *overlayBorder = [[UIImageView alloc] initWithImage:[[UIImage imageFromMainBundleFile:@"jsAlertView_defaultBackground_overlay.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40, 40, 40)]];
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
    _titleLabel.frame = CGRectMake(kTitleOriginX, kTitleLeadingTop, kMaxTitleWidth, _titleSize.height);
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
    self.messageSize = [_messageText sizeWithFont:[UIFont systemFontOfSize:kDefaultMessageFontSize] 
                            constrainedToSize:CGSizeMake(kMaxMessageWidth, kMaxMessageNumberOfLines * kDefaultMessageFontSize) 
                                lineBreakMode:UILineBreakModeTailTruncation];
    _messageLabel.frame = CGRectMake(kMessageOriginX, kTitleLeadingTop + _titleSize.height + kTitleLeadingBottom, kMaxMessageWidth, _messageSize.height);
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
    CGFloat yOrigin = kTitleLeadingTop + _titleSize.height + kTitleLeadingBottom;
    if (_messageLabel) {
        yOrigin += _messageSize.height + kSpacing;
    }
    yOrigin += kSpaceAboveTopButton;
    if (_acceptButtonTitles.count > 1) {
        yOrigin += (kButtonHeight + kSpaceAfterOneOfSeveralActionButtons) * _acceptButtonTitles.count + kSpacing + kSpaceAboveSeparatedCancelButton;
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
    } else if (_acceptButtonTitles.count == 1) {
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMinButtonWidth, kButtonHeight);
    } else {
        _cancelButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
    }
    if (_acceptButtonTitles.count > 0) {
        [_cancelButton setBackgroundImage:[[UIImage imageFromMainBundleFile:@"jsAlertView_iOS_cancelButton_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                                 forState:UIControlStateNormal];
    } else {
        [_cancelButton setBackgroundImage:[[UIImage imageFromMainBundleFile:@"jsAlertView_iOS_okayButton_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                                forState:UIControlStateNormal];
    }
    [_cancelButton setBackgroundImage:[[UIImage imageFromMainBundleFile:@"jsAlertView_iOS_okayCancelButton_highlighted.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                             forState:UIControlStateHighlighted];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.5f] forState:UIControlStateNormal];
    [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    _cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
    _cancelButton.titleLabel.minimumFontSize = kMinimumButtonLabelSize;
    _cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _cancelButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [_littleWindowBG addSubview:_cancelButton];
}

- (void)prepareAcceptButtons {
    for (int index = 0; index < _acceptButtonTitles.count; index++) {
        NSString *buttonTitle = [_acceptButtonTitles objectAtIndex:index];
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat yOrigin = kTitleLeadingTop + _titleSize.height + kTitleLeadingBottom;
        if (_messageLabel) {
            yOrigin += _messageSize.height + kSpacing;
        }
        yOrigin += kSpaceAboveTopButton;
        if (_acceptButtonTitles.count > 1) {
            yOrigin += (kButtonHeight + kSpaceAfterOneOfSeveralActionButtons) * index;
            acceptButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
        } else if (_cancelButtonTitle) {
            acceptButton.frame = CGRectMake(kRightButtonOriginX, yOrigin, kMinButtonWidth, kButtonHeight);
        } else {
            acceptButton.frame = CGRectMake(kLeftButtonOriginX, yOrigin, kMaxButtonWidth, kButtonHeight);
        }
        [acceptButton setBackgroundImage:[[UIImage imageFromMainBundleFile:@"jsAlertView_iOS_okayButton_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                                 forState:UIControlStateNormal];
        [acceptButton setBackgroundImage:[[UIImage imageFromMainBundleFile:@"jsAlertView_iOS_okayCancelButton_highlighted.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)]
                                 forState:UIControlStateHighlighted];
        [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [acceptButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.5f] forState:UIControlStateNormal];
        [acceptButton setTitle:buttonTitle forState:UIControlStateNormal];
        acceptButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [acceptButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        acceptButton.titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
        acceptButton.titleLabel.minimumFontSize = kMinimumButtonLabelSize;
        acceptButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        acceptButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        acceptButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_littleWindowBG addSubview:acceptButton];
        acceptButton.tag = index + 1;
        [_acceptButtons addObject:acceptButton];
    }
}

- (UIImage *)defaultBackgroundImage {
    UIEdgeInsets _defaultBackgroundEdgeInsets = UIEdgeInsetsMake(40, 40, 40, 40);
    if (self.tintColor == nil) {
        self.tintColor = [[JSAlertViewPresenter sharedAlertViewPresenter] defaultColor];
    }
    UIImage *defaultImageWithColor = [UIImage ipMaskedImageNamed:@"jsAlertView_defaultBackground_alphaOnly.png" color:self.tintColor];
    UIImage *_defaultBackgroundImage = [defaultImageWithColor resizableImageWithCapInsets:_defaultBackgroundEdgeInsets];
    return _defaultBackgroundImage;
}

+ (void)setGlobalAcceptButtonDismissalAnimationStyle:(JSAlertViewDismissalStyle)style {
    [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultAcceptDismissalStyle:style];
}

+ (void)setGlobalCancelButtonDismissalAnimationStyle:(JSAlertViewDismissalStyle)style {
    [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultCancelDismissalStyle:style];
}

+ (void)setGlobalTintColor:(UIColor *)tint {
    if (tint == nil) {
        tint = [UIColor colorWithRed:0.02f green:0.06f blue:0.25f alpha:1.0f]; 
    }
    [[JSAlertViewPresenter sharedAlertViewPresenter] setDefaultColor:tint];
}

+ (void)resetDefaults {
    [[JSAlertViewPresenter sharedAlertViewPresenter] resetDefaultAppearance];
}

@end










