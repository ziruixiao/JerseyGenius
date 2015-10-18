//
//  MTMiniPopupWindow.h
//  Created by Felix Xiao
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "Jersey.h"
#import "Level.h"
#import "LevelViewController.h"

@interface MTMiniPopupWindow : NSObject
{
    UIView* bgView;
    UIView* bigPanelView;
}

//declare properties
@property (nonatomic, retain, readwrite) UILabel *titleLabel;
@property (nonatomic, retain, readwrite) UILabel *messageLabel;

//declare methods
+ (void)showWindowWithTitle:(NSString*)title andMessage:(NSString*)message alertID:(NSString*)alertID insideView:(UIView*)view;

@end
