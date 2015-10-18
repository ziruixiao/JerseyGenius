//
//  MTPopupWindow.h
//  Created by Felix Xiao
//  

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "Jersey.h"
#import "LevelViewController.h"
#import "Level.h"
#import "MTMiniPopupWindow.h"

@interface MTPopupWindow : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
{
    UIView* bgView;
    UIScrollView* bigPanelView;
    CGFloat animatedDistance;
}

//declare properties
@property (nonatomic, retain, readwrite) Jersey* popJersey;
@property (nonatomic, retain, readwrite) Level* parentLevel;
@property (nonatomic, retain, readwrite) Player* player;
@property (nonatomic, retain, readwrite) UIView* parentFull;
@property (nonatomic, retain, readwrite) UIScrollView* parentView;
@property (nonatomic, retain, readwrite) UITapGestureRecognizer* tap;

@property (nonatomic, retain, readwrite) UITextField* guessTextField;
@property (nonatomic, retain, readwrite) UILabel* valueLabel;
@property (nonatomic, retain, readwrite) UIButton* checkButton;
@property (nonatomic, retain, readwrite) UIImageView* statusImage;

@property (nonatomic, retain, readwrite) UILabel* solvedLabel;
@property (nonatomic, retain, readwrite) UIView* line1;
@property (nonatomic, retain, readwrite) UILabel* solvedLabel2;
@property (nonatomic, retain, readwrite) UIView* line2;
@property (nonatomic, retain, readwrite) UILabel* solvedLabel3;
@property (nonatomic, retain, readwrite) UIButton* guessTab;
@property (nonatomic, retain, readwrite) UIButton* hintsTab;
@property (nonatomic, retain, readwrite) NSMutableArray* allLevels;
@property (strong) AVAudioPlayer *click;

//declare methods
+ (void)showWindowWithJersey:(Jersey*)selectedJersey insideView:(UIView*)view forLevel:(Level*)parentGameLevel andScroll:(UIScrollView*)scroll andLevelsArray: (NSMutableArray*)allLevels;
- (int)getRandomNumber:(int)from to:(int)to;
- (void)playClick;

@end
