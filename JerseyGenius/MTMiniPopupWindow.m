//
//  MTMiniPopupWindow.m
//  Created by Felix Xiao
//

#import "AppDelegate.h"
#import "MTMiniPopupWindow.h"

#define kShadeViewTag 300

@interface MTMiniPopupWindow(Private)
- (id)initWithSuperview:(UIView*)sview andFile:(NSString*)fName;
@end


@implementation MTMiniPopupWindow

//synthesize properties
@synthesize titleLabel = _titleLabel;
@synthesize messageLabel = _messageLabel;

//implement methods
//CREATES A NEW MTMINIPOPUPWINDOW WITH A SPECIFIED VIEW, TITLE, MESSAGE, and ALERT ID
+ (void)showWindowWithTitle:(NSString*)title andMessage:(NSString*)message alertID:(NSString*)alertID insideView:(UIView*)view
{
    [[[MTMiniPopupWindow alloc] initWithSuperview:view andTitle:title andMessage:message alertID:alertID] autorelease];
}

//INITIALIZES A NEW MTMINIPOPUPWINDOW WITH A SPECIFIED VIEW, TITLE, MESSAGE, and ALERT ID
- (id)initWithSuperview:(UIView*)sview andTitle:(NSString*)title andMessage:(NSString*)message alertID:(NSString*)alertID
{
    self = [super init];
    if (self) {
        bgView = [[[UIView alloc] initWithFrame: sview.bounds] autorelease];
        [sview addSubview: bgView];
        
        //setup for the title label
        CGRect titleFrame = CGRectMake(0,0,180,30);
        self.titleLabel = [[[UILabel alloc] initWithFrame:titleFrame] autorelease];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.text = title;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:29.0f];
        self.titleLabel.textColor = [UIColor blackColor];
        
        //setup for the messsage label
        CGRect messageFrame = CGRectMake(0,0,180,40);
        self.messageLabel = [[[UILabel alloc] initWithFrame:messageFrame] autorelease];
        self.messageLabel.textAlignment = UITextAlignmentCenter;
        self.messageLabel.text = message;
        self.messageLabel.numberOfLines = 2;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.messageLabel.textColor = [UIColor whiteColor];
        
        //load the mini popup window
        [self performSelector:@selector(doTransitionWithContentFile:) withObject:alertID afterDelay:0.1];
    }
    return self;
}

//LOADS THE CREATED MTMINIPOPUPWINDOW BASED ON THE ALERT ID
- (void)doTransitionWithContentFile:(NSString*)alertID //INCOMPLETE
{
    //faux view
    UIView* fauxView = [[[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)] autorelease];
    [bgView addSubview: fauxView];

    //the new panel
    bigPanelView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)] autorelease];
    bigPanelView.center = CGPointMake( bgView.frame.size.width/2, bgView.frame.size.height/2);
    
    //add the window background
    UIImageView* background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popupWindowBackSmall.png"]] autorelease];
    background.center = CGPointMake(bigPanelView.frame.size.width/2, bigPanelView.frame.size.height/2);
    [bigPanelView addSubview: background];    
    
    //center the labels
    self.titleLabel.center = CGPointMake(bigPanelView.frame.size.width/2, bigPanelView.frame.size.height/2-45);
    self.messageLabel.center = CGPointMake(bigPanelView.frame.size.width/2, bigPanelView.frame.size.height/2);
    [bigPanelView addSubview:self.titleLabel];
    [bigPanelView addSubview:self.messageLabel];
    
    //create a big close button
    UIButton *bigCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bigCloseBtn setImage:[UIImage imageNamed:@"backtogame.png"] forState:UIControlStateNormal];
    [bigCloseBtn addTarget:self action:@selector(closePopupWindow) forControlEvents:UIControlEventTouchUpInside];
    [bigCloseBtn setFrame:CGRectMake(110,255,100,40)];
    [bigPanelView addSubview:bigCloseBtn];
    
    //create a small corner close button
    int closeBtnOffset = 10;
    UIImage* closeBtnImg = [UIImage imageNamed:@"popupCloseBtn.png"];
    UIButton* closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:closeBtnImg forState:UIControlStateNormal];
    [closeBtn setFrame:CGRectMake(background.frame.origin.x + background.frame.size.width - closeBtnImg.size.width - closeBtnOffset, 
        background.frame.origin.y, closeBtnImg.size.width + closeBtnOffset, closeBtnImg.size.height + closeBtnOffset)];
    [closeBtn addTarget:self action:@selector(closePopupWindow) forControlEvents:UIControlEventTouchUpInside];
    [bigPanelView addSubview: closeBtn];
    
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction |
        UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animation
    [UIView transitionFromView:fauxView toView:bigPanelView duration:0.1 options:options completion: ^(BOOL finished) {
        //dim the contents behind the popup window
        UIView* shadeView = [[[UIView alloc] initWithFrame:bigPanelView.frame] autorelease];
        shadeView.backgroundColor = [UIColor blackColor];
        shadeView.alpha = 0.3;
        shadeView.tag = kShadeViewTag;
        [bigPanelView addSubview: shadeView];
        [bigPanelView sendSubviewToBack: shadeView];
    }];
}

//CLOSES THE MTMINIPOUPWINDOW AND CALLS AN ANIMATION
- (void)closePopupWindow
{
    //remove the shade
    [[bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
    [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
}

//ANIMATES CLOSING OF MTMINIPOPUPWINDOW
- (void)closePopupWindowAnimate
{
    //faux view
    __block UIView* fauxView = [[[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)] autorelease];
    [bgView addSubview: fauxView];

    //run the animation
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction |
        UIViewAnimationOptionBeginFromCurrentState;
    
    //hold to the bigPanelView, because it'll be removed during the animation
    [bigPanelView retain];
    
    [UIView transitionFromView:bigPanelView toView:fauxView duration:0.1 options:options completion:^(BOOL finished) {
        //when popup is closed, remove all the views
        for (UIView* child in bigPanelView.subviews) {
            [child removeFromSuperview];
        }
        for (UIView* child in bgView.subviews) {
            [child removeFromSuperview];
        }
        [bigPanelView release];
        [bgView removeFromSuperview];

        [self release];
    }];
}

@end