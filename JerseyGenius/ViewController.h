//
//  ViewController.h
//  Created by Felix Xiao
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <CommonCrypto/CommonDigest.h>
#import "Player.h"
#import <iAd/iAd.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, ADBannerViewDelegate>{
    CGFloat animatedDistance; //declare CGFloat for keyboard view transition
    ADBannerView *adView;
    BOOL bannerIsVisible;
}
//declare properties

@property (nonatomic, assign) BOOL bannerIsVisible;

@property int levelCount;
@property (retain, nonatomic, readwrite) NSMutableArray *allLevels;
@property (retain, nonatomic, readwrite) Player *player;
@property (retain, nonatomic) IBOutlet UIButton *resetButton;
@property (retain, nonatomic) IBOutlet UIButton *infoButton;
@property (retain, nonatomic) IBOutlet UIButton *buyhintsButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

//declare methods
- (IBAction)back:(id)sender;
- (IBAction)showInstructions;
- (void)profileCheck;
- (void)checkLevels;
- (void)changeSound;
- (IBAction)resetGame;
- (IBAction)buyHint;

@end
