//
//  ViewController.m
//  JerseyGenius
//
//  Created by Felix Xiao on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "MTBlankPopupWindow.h"

@interface ViewController ()

@end

@implementation ViewController {
    sqlite3 *DB_Jerseys;
    NSString *databasePath;
    NSString *docsDir;
    NSArray *dirPaths;
}

@synthesize bannerIsVisible;

//declare static values for keyboard animation
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

//synthesize properties
@synthesize levelCount = _levelCount;
@synthesize allLevels = _allLevels;
@synthesize player = _player;
@synthesize resetButton = _resetButton;
@synthesize infoButton;
@synthesize buyhintsButton;

//implement methods
//OVERRIDES WHAT HAPPENS WHEN A TEXTFIELD IS SELECTED, SHIFTS SCREEN UP TO ALLOW FOR KEYBOARD
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

//OVERRIDES WHAT HAPPENS WHEN A TEXTFIELD IS CLOSED, SHIFTS SCREEN BACK DOWN
- (void)textFieldDidEndEditing:(UITextField *)textField //allows the view to return to normal after keyboard is gone
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

//DISMISSES THE MODAL VIEW CONTROLLER AND RETURNS TO PREVIOUS PAGE
- (IBAction)back:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [super viewDidLoad];
}

//CHECKS AND LOADS THE CURRENT PLAYER PROFILE
- (void)profileCheck
{
    self.player = [[[Player alloc] init] autorelease];
    [self.player loadProfile:self.player];
}

- (IBAction)loadLevels
{
    [self.activityView startAnimating];
}
//CHECK FOR THE CURRENT LEVELS
- (void)checkLevels
{
    //connect to the database
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"DB_Jerseys.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open_v2(dbpath, &DB_Jerseys, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        //STEP ONE: Fill levelPlayers MutableArray with fullName of all players matching levelIdentifier
        //STEP TWO: Fill levelJerseys MutableArray with jerseys of all players matching levelIdentifier
        NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM jerseys ORDER BY level ASC"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(DB_Jerseys, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            NSString *temp = @"";
            self.allLevels = [[[NSMutableArray alloc] init] autorelease];
            self.levelCount = 0;
            while (sqlite3_step(statement) == SQLITE_ROW) {
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                if (![self.allLevels containsObject:temp]) {
                    [self.allLevels addObject:temp];
                    self.levelCount+=1;
                }
                [temp release];
            }
        } else {
            NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys));
        }
    } else {
        NSLog(@"something went really wrong");
    }
    [databasePath release];
}

//UPDATES THE SOUND PREFERENCES TO THE OPPOSITE OF BEFORE
- (void)changeSound
{
    if (self.player.sound==YES) {
        self.player.sound = NO;
        [self.player updateProfile:self.player inField:@"sound" toNew:nil ifInt:0];
    } else {
        self.player.sound = YES;
        [self.player updateProfile:self.player inField:@"sound" toNew:nil ifInt:1];
    }
    [self viewDidLoad];
}

//RESETS THE GAME DATABASES
- (IBAction)resetGame
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Reset Game"
                                                      message:@"Are you sure you want to reset JerseyGenius? All jerseys, levels, and points will be cleared. Your hint count will be restored to 20."
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
    
    [message addButtonWithTitle:@"Continue"];
    
    [message show];
    [message release];
    
}

- (IBAction)showInstructions
{
    [MTBlankPopupWindow showWindowWithView:self.view];
    //[self.view bringSubviewToFront:adView];
}

//ALLOWS FOR A HINT TO BE PURCHASED
- (IBAction)buyHint
{
    
}

//OVERRIDES THE WAY ALERT RESPONSES ARE DEALT WITH
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Continue"])
    {
        //reset the jerseys
        Level *sampleLevel = [[Level alloc] init];
        [sampleLevel resetGame];
        [sampleLevel release];
        
        //reset the profiles table
        [self.player updateProfile:self.player inField:@"profilePoints" toNew:nil ifInt:0];
        [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:20];
    }

}

//LOAD THE CONTROLLER VIEW
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityView stopAnimating];

    
    
    //draw logo picture
    if ([self.title isEqualToString:@"MainMenu"]) {
        UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainImage.png"]];
        logoImage.frame = CGRectMake(20,20,280,220);
        [self.view addSubview:logoImage];
        [logoImage release];
        
        //draw background picture
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"sportsbgfire.png"]];
        self.view.backgroundColor = background;
        [background release];
    } else {
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"sportsbg.png"]];
        self.view.backgroundColor = background;
        [background release];
    }
    
    [self profileCheck];
    
    if ([self.title isEqualToString:@"Other"]||[self.title isEqualToString:@"Info"]) {
        //create top bar view
        CGRect topbarFrame = CGRectMake(0,0,321,70);
        UIView* topbarView = [[UIView alloc] initWithFrame:topbarFrame];
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"topbar.png"]];
        topbarView.backgroundColor = background;
        [background release];
        [self.view addSubview:topbarView ];
        [self.view sendSubviewToBack:topbarView];
        [topbarView release];
        
        
        //create top bar image
        CGRect nameFrame = CGRectMake(100,5,210,35);
        UIImageView *nameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topbarName.png"]];
        nameImageView.frame = nameFrame;
        [self.view addSubview:nameImageView];
        [nameImageView release];
        
        //create top bar points label
        CGRect pointsFrame = CGRectMake(100,45,120,20);
        UILabel *pointsLabel = [[[UILabel alloc] initWithFrame:pointsFrame] autorelease];
        pointsLabel.text = [NSString stringWithFormat:@"Points: %i", self.player.playerPoints];
        pointsLabel.textAlignment =UITextAlignmentCenter;
        pointsLabel.textColor = [UIColor whiteColor];
        pointsLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        pointsLabel.tag = -100; //pointsLabel tag is -100
        pointsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pointsBackground.png"]];
        [self.view addSubview:pointsLabel];
        
        //create top bar hints label
        CGRect hintsFrame = CGRectMake(230,45,80,20);
        UILabel *hintsLabel = [[[UILabel alloc] initWithFrame:hintsFrame] autorelease];
        hintsLabel.text = [NSString stringWithFormat:@"Hints: %i", self.player.playerHints];
        hintsLabel.textAlignment = UITextAlignmentCenter;
        hintsLabel.tag = -101; //hintsLabel tag is -101
        hintsLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        hintsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hintsBackground.png"]];
        [self.view addSubview:hintsLabel];

        if ([self.title isEqualToString:@"Other"]) {
            UIButton *soundbtn = [UIButton buttonWithType:UIButtonTypeCustom];
            soundbtn.frame = CGRectMake(30,60,260,100);
            
            if (self.player.sound==YES) {
                [soundbtn setBackgroundImage:[UIImage imageNamed:@"soundOn.png"] forState:UIControlStateNormal];
            } else {
                [soundbtn setBackgroundImage:[UIImage imageNamed:@"soundOff.png"] forState:UIControlStateNormal];
            }
            [soundbtn addTarget:self action:@selector(changeSound) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:soundbtn];
        }

    }
    
    
        
	// Do any additional setup after loading the view, typically from a nib.
    [self checkLevels];

    
}

//LOADS THE AD BANNER WHEN POSSIBLE
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -50.0f);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

//HIDES THE AD BANNER WHEN A CONNECT ISN'T AVAILABLE
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, 50.0f);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
        adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        adView.frame = CGRectOffset(adView.frame, 0, 460.0f);
        adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
        adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        [self.view addSubview:adView];
        adView.delegate = self;
        self.bannerIsVisible = NO;
    
    [self.view bringSubviewToFront:adView];
    [adView release];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.activityView stopAnimating];
    [adView removeFromSuperview];
}

//UNLOAD THE CONTROLLER VIEW
- (void)viewDidUnload
{
    [self setResetButton:nil];
    [self setInfoButton:nil];
    [self setBuyhintsButton:nil];
    [self setActivityView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//SET ORIENTATION DEFAULTS
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation //complete
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//DEALLOCATE MEMORY
- (void)dealloc
{
    [_resetButton release];
    [infoButton release];
    [buyhintsButton release];
    [_activityView release];
    [super dealloc];
}

@end
