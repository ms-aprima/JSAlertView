JSAlertView
by Jared Sinclair  -  http://www.jaredsinclair.com




What is JSAlertView?
====================

JSAlertView is an easily-customizable, drop-in replacement for UIAlertView in your iOS apps. Out of the box, JSAlertView is nearly indistinguishable from UIAlertView in appearance and behavior. But you can customize JSAlertView by 1) setting a tint color or 2) choosing an alternate dismissal animation. 



UIAlertView — vs — JSAlertView
==============================

Implementing JSAlertView is almost exactly the same as UIAlertView. For the most part, you should only have to change the "UI" class prefix to "JS" to make the change. There is a delegate protocol called JSAlertViewDelegate which shares the same structure and behavior as UIAlertView, with one exception: JSAlertView will never be auto-dismissed in response to application state changes (background, incoming call, etc.). JSAlertView *is* automatically dismissed by tapping any of its buttons, however.



Image Resources
===============

JSAlertView requires 11 image files to render properly on all screens. These are included in the JSAlertViewSample.app project above. The total size of all 11 images is 119kb. 

The background radial shadow that overlays the window is pre-rendered in Photoshop to avoid the (even worse) banding that appears when drawing them in code. If you can find a way to draw these gradients in code without banding, please let me know @jaredsinclar!




Working with JSAlertView
========================

Just import JSAlertView.h into any class you wish to create an alert view or become a delegate. JSAlertView handles showing/hiding alert views through a private singleton class called JSAlertViewPresenter. Whenever "show" is called on a JSAlertView, it is added to the JSAlertViewPresenter's queue of alert views. If there is already an alert view visible, JSAlertViewPresenter will queue it, presenting subsequent alert views in the order they were told to show. JSAlertViewPresenter also handles the allocation / deallocation of the overlay window (background shadow gradient) that is superimposed over the entire screen. In order for this behavior to work properly, your application's keyWindow must its rootViewController property set before using JSAlertView.




Setting a Tint Color
====================

You can set a tint color for JSAlertView, either as a global setting via:

+ (void)setGlobalTintColor:(UIColor*)tint;

Alternatively, you can override the global tint color by setting the "tintColor" property of an instance of JSAlertView:

@property (nonatomic, strong) UIColor *tintColor; 

The code for setting the tint color is based on [IPImageUtils by Ole Zorn][zorn].




Choosing Dismissal Animations
=============================

JSAlertView supports four types of dismissal animations:

1. Fade — A simple fade, the iOS default for UIAlertView
2. Fall — Similar to the Tweetbot cancel-style.
3. Shrink — The alert view shrinks and fades into nothing.
4. Expand — The alert view quickly expands and fades.

You can set these animation styles via the JSAlertViewDismissalStyle enumeration. Different animations may be set for the cancel button and for any other button respectively. These settings can be set as global options:

+ (void)setGlobalAcceptButtonDismissalAnimationStyle:(JSAlertViewDismissalStyle)style;
+ (void)setGlobalCancelButtonDismissalAnimationStyle:(JSAlertViewDismissalStyle)style;

Alternatively, you can override them for a given instance of JSAlertView:

@property (nonatomic, assign) JSAlertViewDismissalStyle cancelButtonDismissalStyle;
@property (nonatomic, assign) JSAlertViewDismissalStyle acceptButtonDismissalStyle;



Resetting Defaults
==================

Reset to the default parameters for both color and animation by calling the class method:

+ (void)resetDefaults;




License Agreement
=================

Check the end of this doc for the license agreement. But you can use, modify, or share this pretty much as you see fit. Just include attribution in your credits!




License Agreement for Source Code provided by Jared Sinclair
===========================================================

This software is supplied to you by Jared Sinclair in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this software constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or redistribute this software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Jared Sinclair grants you a personal, non-exclusive license, to use, reproduce, modify and redistribute the software, with or without modifications, in source and/or binary forms; provided that if you redistribute the software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the software, and that in all cases attribution of Jared Sinclair as the original author of the source code shall be included in all such resulting software products or distributions. Neither the name, trademarks, service marks or logos of Jared Sinclair may be used to endorse or promote products derived from the software without specific prior written permission from Jared Sinclair. Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Jared Sinclair herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the software may be incorporated.

The software is provided by Jared Sinclair on an "AS IS" basis. JARED SINCLAIR MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL JARED SINCLAIR BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF JARED SINCLAIR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[zorn]: https://gist.github.com/1102091/b196c1ec001d1a69b9940f0f32043d62d5f596d4