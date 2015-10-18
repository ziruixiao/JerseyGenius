//
//  MenuViewController.h
//  Created by Felix Xiao
//
//

#import "Player.h"
#import "ViewController.h"
#import "LevelViewController.h"

@interface MenuViewController : ViewController <LevelViewControllerDelegate, UIScrollViewDelegate>
{
	IBOutlet UIScrollView* scrollView;
	IBOutlet UIPageControl* pageControl;
	
    BOOL pageControlIsChangingPage;
}

//declare properties
@property (retain, nonatomic, readwrite) NSString *selectedLevel;
@property (retain, nonatomic, readwrite) UIScrollView* menuScroll;
@property (retain, nonatomic, readwrite) Player* player;
@property (retain, nonatomic, readwrite) UILabel* pointsLabel;
@property (retain, nonatomic, readwrite) UILabel* hintsLabel;
@property (retain, nonatomic, readwrite) UILabel* percentButton;
@property (nonatomic, retain) UIView *scrollView;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (nonatomic, retain, readwrite) UIImageView* lockImageView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *levelLoadActivity;

//declare methods
- (IBAction)changePage:(id)sender;
- (void)setupPage;

@end
