//
//  MenuViewController.m
//  Created by Felix Xiao
//

#import "AppDelegate.h"
#import "Player.h"
#import "MenuViewController.h"
#import "LevelViewController.h"

//define values for scrollview and pagination
#define BUTTON_WIDTH 300
#define BUTTON_HEIGHT 300
#define BUTTON_PADDING 20
#define BUTTONS_PER_PAGE 4
#define PAGE_WIDTH ((BUTTON_WIDTH + BUTTON_PADDING) * BUTTONS_PER_PAGE)
#define MAGIC_BUTTON_TAG_OFFSET 6238 

@interface MenuViewController ()

@end

@implementation MenuViewController

//synthesize properties
@synthesize selectedLevel = _selectedLevel;
@synthesize menuScroll = _menuScroll;
@synthesize player = _player;
@synthesize pointsLabel = _pointsLabel;
@synthesize hintsLabel = _hintsLabel;
@synthesize percentButton = _percentButton;
@synthesize scrollView;
@synthesize pageControl;
@synthesize lockImageView = _lockImageView;

//implement methods
//UPDATES POINTS AND HINTS LABELS WITH SPECIFIED STRING, LEVEL ID, and PLAYER PROFILE
- (void)finishedDoingMyThing:(NSString *)labelString withId:(NSString*)levelIdentifier andPlayer:(Player*)returnedPlayer
{
    [self dismissModalViewControllerAnimated:YES];
    
    [self.pointsLabel setText:[NSString stringWithFormat:@"Points: %i", returnedPlayer.playerPoints]];
    [self.hintsLabel setText:[NSString stringWithFormat:@"Hints: %i", returnedPlayer.playerHints]];
    
    int desiredTag = 0;
    int desiredTag2 = -903;
    int desiredTag3 = -904;
    
    NSString *secondString = @"";
    
    for (int x = 0; x < labelString.length; x++) {
        if ([[labelString substringWithRange:NSMakeRange(x,1)] isEqualToString:@" "]) {
            break;
        }
        secondString = [secondString stringByAppendingString:[labelString substringWithRange:NSMakeRange(x,1)]];
    }
    int newInt = [secondString intValue];
     
    //1nba: 17000, 1nfl:17001, 2nba:17002, 2nfl:17003, 3nfl:17004, 4nfl:17005
    
    if ([levelIdentifier isEqualToString:@"1NBA"]) {
        desiredTag = 200;
        if (newInt>=50) {
            //level 2NBA should be unlocked, 6238+2
            desiredTag2 = 6240;
            desiredTag3 = 202; 
            //clear self.lockImageView
            for (UIImageView *lock in scrollView.subviews) {
                if (lock.tag==17002) {
                    lock.image = nil;
                }
            }
        }
    }
    if ([levelIdentifier isEqualToString:@"2NBA"]) { desiredTag = 202; }
    if ([levelIdentifier isEqualToString:@"1NFL"]) {
        desiredTag = 201;
        if (newInt>=50) {
            //level 2NFL should be unlocked, 6238+3
            desiredTag2 = 6241;
            desiredTag3 = 203;
            //clear self.lockImageView
            for (UIImageView *lock in scrollView.subviews) {
                if (lock.tag==17003) {
                    lock.image = nil;
                }
            }
        }
    }
    if ([levelIdentifier isEqualToString:@"2NFL"]) {
        desiredTag = 203;
        if (newInt>=50) {
            //level 2NFL should be unlocked, 6238+3
            desiredTag2 = 6242;
            desiredTag3 = 204;
            //clear self.lockImageView
            for (UIImageView *lock in scrollView.subviews) {
                if (lock.tag==17004) {
                    lock.image = nil;
                }
            }
        }
    }
    if ([levelIdentifier isEqualToString:@"3NFL"]) {
        desiredTag = 204;
        if (newInt>=50) {
            //level 2NFL should be unlocked, 6238+3
            desiredTag2 = 6243;
            desiredTag3 = 205;
            //clear self.lockImageView
            for (UIImageView *lock in scrollView.subviews) {
                if (lock.tag==17005) {
                    lock.image = nil;
                }
            }
        }
    }
    if ([levelIdentifier isEqualToString:@"4NFL"]) {
        desiredTag = 205;
    }
    for (UILabel *label in scrollView.subviews) {
        if (label.tag==desiredTag) {
            [label setText:labelString];
        }
    }
    for (UIButton *button in scrollView.subviews) {
        if (button.tag==desiredTag2) {
            //set button data
            NSString *newImageString = @"";
            if (button.tag==6240) {
                newImageString = [newImageString stringByAppendingString:@"2NBA"];
            }
            if (button.tag==6241) {
                newImageString = [newImageString stringByAppendingString:@"2NFL"];
            }
            if (button.tag==6242) {
                newImageString = [newImageString stringByAppendingString:@"3NFL"];
            }
            if (button.tag==6243) {
                newImageString = [newImageString stringByAppendingString:@"4NFL"];
            }
            
            newImageString = [newImageString stringByAppendingFormat:@".png"];
            
            [button setBackgroundImage:[UIImage imageNamed:newImageString] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [button setEnabled:YES];
        }
    }
    for (UILabel *label in scrollView.subviews) {
        if (label.tag==desiredTag3) {
            if ([label.text isEqualToString:@"Solve jerseys to unlock."]) {
                [label setText:@"0% Complete"];
            }
        }
    }
}

//INITIALIZES A MENUVIEWCONTROLLER
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//LOADS THE VIEW
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.levelLoadActivity stopAnimating];
    [self.view bringSubviewToFront:adView];
    
    //create top bar view
    CGRect topbarFrame = CGRectMake(0,0,321,70);
    UIView* topbarView = [[UIView alloc] initWithFrame:topbarFrame];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"topbar.png"]];
    topbarView.backgroundColor = background;
    [background release];
    [self.view addSubview:topbarView ];
    [self.view sendSubviewToBack:topbarView];
    [topbarView release];
    
    //reload player profile
    self.player = [[[Player alloc] init] autorelease];
    [self.player loadProfile:self.player];
    
    //create top bar image
    CGRect nameFrame = CGRectMake(100,5,210,35);
    UIImageView *nameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topbarName.png"]];
    nameImageView.frame = nameFrame;
    [self.view addSubview:nameImageView];
    [nameImageView release];
    
    //create top bar points label
    CGRect pointsFrame = CGRectMake(100,45,120,20);
    self.pointsLabel = [[[UILabel alloc] initWithFrame:pointsFrame] autorelease];
    self.pointsLabel.text = [NSString stringWithFormat:@"Points: %i", self.player.playerPoints];
    self.pointsLabel.textAlignment =UITextAlignmentCenter;
    self.pointsLabel.textColor = [UIColor whiteColor];
    self.pointsLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.pointsLabel.tag = -100; //pointsLabel tag is -100
    self.pointsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pointsBackground.png"]];
    [self.view addSubview:self.pointsLabel];
    
    //create top bar hints label
    CGRect hintsFrame = CGRectMake(230,45,80,20);
    self.hintsLabel = [[[UILabel alloc] initWithFrame:hintsFrame] autorelease];
    self.hintsLabel.text = [NSString stringWithFormat:@"Hints: %i", self.player.playerHints];
    self.hintsLabel.textAlignment = UITextAlignmentCenter;
    self.hintsLabel.tag = -101; //hintsLabel tag is -101
    self.hintsLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.hintsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hintsBackground.png"]];
    [self.view addSubview:self.hintsLabel];
    
    [self setupPage];
}

//SETS UP THE MENU
- (void)setupPage
{
	scrollView.delegate = self;
    
	[self.scrollView setBackgroundColor:[UIColor clearColor]];
	[scrollView setCanCancelContentTouches:NO];
	
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;
	scrollView.scrollEnabled = YES;
	scrollView.pagingEnabled = YES;
	
	CGFloat cx = 0;
    
    NSString *buttonLabel = @"";
    Level *tempLevel = [Level alloc];
    NSString *tempString;
    for (int i = 0; i < self.allLevels.count; i++) {
        //create level first
        [tempLevel createLevel:tempLevel withName:[self.allLevels objectAtIndex:i]];
        
        //create a button for the level select
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(50, 85, 220, 250);
        
        btn.tag = i + MAGIC_BUTTON_TAG_OFFSET; // to relate to the array index
        buttonLabel = (NSString*)[self.allLevels objectAtIndex:i];
        buttonLabel = [buttonLabel stringByAppendingFormat:@".png"];
        
        CGRect rect = btn.frame;
		rect.size.height = 250;
		rect.size.width = 220;
		rect.origin.x = ((scrollView.frame.size.width - 220) / 2) + cx;
		rect.origin.y = ((scrollView.frame.size.height - 250) / 2-12);
		btn.frame = rect;
        
        //btn.tag = 1000+i; //1NBA would be level 1001, 1NFL 1002, 2NBA 1003, 2NFL 1004, 3NFL 1005, 4NFL 1006
        if ([tempLevel.levelName isEqualToString:@"Soon"]) {
            [btn setBackgroundImage:[UIImage imageNamed:buttonLabel] forState:UIControlStateDisabled];
            [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [btn setEnabled:NO];
            [scrollView addSubview:btn];
            tempString = [NSString stringWithFormat:@"Rate 5 Stars for Levels!"];
        }
        else if (tempLevel.prevLevelSolved<15) { //this level is locked
            [btn setEnabled:NO];
            [btn setBackgroundImage:[self convertImageToGrayScale:[UIImage imageNamed:buttonLabel]] forState:UIControlStateDisabled];
             //[btn setTag:(1000+i)];
            [scrollView addSubview:btn];
            //add a lock
            self.lockImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]] autorelease];
            self.lockImageView.center = btn.center;
            self.lockImageView.tag = 17000+i;
            
            [scrollView addSubview:self.lockImageView];
            tempString = @"Solve jerseys to unlock.";
        } else { //this level is unlocked
            [btn setBackgroundImage:[UIImage imageNamed:buttonLabel] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [btn setEnabled:YES];
            //[btn setTag:(1000+i)];
            [scrollView addSubview:btn];
            tempString = [NSString stringWithFormat:@"%i%% complete", tempLevel.percentComplete];
        }
        
        if (tempLevel.percentComplete==100) {
            UIImageView *checkmark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]] autorelease];
            checkmark.center = btn.center;
            [scrollView addSubview:checkmark];
        }
        
        //create percent complete
        CGRect percentFrame = CGRectMake(50+cx, 265, 200, 25);
        self.percentButton = [[[UILabel alloc] initWithFrame:percentFrame] autorelease];
        self.percentButton.backgroundColor = [UIColor clearColor];
        self.percentButton.text = tempString;
        self.percentButton.textAlignment = UITextAlignmentCenter;
        self.percentButton.tag = 200+i; //1NBA is 200, 2NBA is 201, 1NFL is 202, 2NFL is 203, 3NFL is 204, 4NFL is 205
        self.percentButton.font = [UIFont boldSystemFontOfSize:16.0f];
        self.percentButton.textColor = [UIColor blackColor];
        [scrollView addSubview:self.percentButton];
        
        cx += scrollView.frame.size.width;
    }
    
    self.pageControl.numberOfPages = self.allLevels.count;
	[scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
    [tempLevel release];
    
}

//CONVERTS AN IMAGE TO GRAYSCALE
- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    /* changes start here */
    // Create bitmap image info from pixel data in current context
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    // release the colorspace and graphics context
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    // make a new alpha-only graphics context
    context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, nil, kCGImageAlphaOnly);
    // draw image into context with no colorspace
    CGContextDrawImage(context, imageRect, [image CGImage]);
    // create alpha bitmap mask from current context
    CGImageRef mask = CGBitmapContextCreateImage(context);
    // release graphics context
    CGContextRelease(context);
    // make UIImage from grayscale image with alpha mask
    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
    // release the CG images
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    // return the new grayscale image
    return grayScaleImage;
    /* changes end here */
}

//OVERRIDES THE ACTIONS FOR WHAT HAPPENS WHEN THE SCROLLVIEW STARTS MOVING
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) {
        return;
    }
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

//OVERRIDES THE ACTIONS FOR WHAT HAPPENS WHEN THE SCROLLVIEW STOPS MOVING
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    pageControlIsChangingPage = NO;
}

//CHANGES THE PAGE OF THE PAGECONTROL
- (IBAction)changePage:(id)sender
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlIsChangingPage = YES;
}



//LOADS THE LEVEL AFTER THE BUTTON IS PRESSED
- (void)buttonPressed:(UIButton *)btn
{
    [self.levelLoadActivity startAnimating];
    int index = btn.tag - MAGIC_BUTTON_TAG_OFFSET;
    id object = [self.allLevels objectAtIndex:index];
    
    self.selectedLevel = object;
    UIStoryboard *storyboard = self.storyboard;
    LevelViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"GameLevel"];
    svc.modalTransitionStyle =  UIModalTransitionStyleCrossDissolve;
    [svc setLevelIdentifier:self.selectedLevel];
    svc.delegate = self;
    svc.allLevels = super.allLevels;
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:YES];
    [self.levelLoadActivity stopAnimating];
    
}

//UNLOADS THE VIEW
- (void)viewDidUnload
{
    [self setLevelLoadActivity:nil];
    [self.levelLoadActivity stopAnimating];
    [super viewDidUnload];
    [scrollView release];
	[pageControl release];
    // Release any retained subviews of the main view.
}

//SET ORIENTATION DEFAULTS
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation //complete
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [_levelLoadActivity release];
    [super dealloc];
}
@end
