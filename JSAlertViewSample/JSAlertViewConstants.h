//
//  JSAlertViewConstants.h
//  JSAlertViewSample
//
//  Created by Jared Sinclair on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

typedef enum {
    JSAlertViewDismissalStyleShrink, 
    JSAlertViewDismissalStyleFall, // Like Tweetbot
    JSAlertViewDismissalStyleExpand, // Like Reeder
    JSAlertViewDismissalStyleFade, // The iOS default looks like this
} JSAlertViewDismissalStyle;

#define kCancelButtonIndex 0
#define kAcceptButtonIndex 1