//
//  LevelViewController.h
//  Created by Felix Xiao
//

#import "Level.h"
#import "Jersey.h"
#import "Player.h"
#import "ViewController.h"
#import "MTPopupWindow.h"
#import "MTMiniPopupWindow.h"

@protocol LevelViewControllerDelegate
-(void)finishedDoingMyThing:(NSString *)labelString withId:(NSString*)levelIdentifier andPlayer:(Player*)returnedPlayer;
@end

__unsafe_unretained id <LevelViewControllerDelegate> _delegate;

@interface LevelViewController : ViewController <UIScrollViewDelegate>
{
	IBOutlet UIScrollView* scrollView;
	IBOutlet UIPageControl* pageControl;
	
    BOOL pageControlIsChangingPage;
}

//declare properties
@property (nonatomic, retain, readwrite) NSString *levelIdentifier;
@property (nonatomic, retain, readwrite) Level *gameLevel;
@property (retain, nonatomic, readwrite) UIScrollView* levelScroll;
@property (retain, nonatomic, readwrite) UIButton* percentDone;
@property (retain, nonatomic, readwrite) Player* player;
@property (retain, nonatomic, readwrite) UILabel* hintsLabel;
@property (nonatomic, assign) id <LevelViewControllerDelegate> delegate;
@property (nonatomic, retain) UIView *scrollView;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (nonatomic, retain, readwrite) NSMutableArray *allLevels;

//declare methods
- (IBAction)changePage:(id)sender;
- (void)loadLevel:(Level*)level;
- (UIImage *)convertImageToGrayScale:(UIImage *)image;
- (void)jerseyPressed:(UIButton *)btn;
- (IBAction)back:(id)sender;

@end
