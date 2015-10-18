//
//  LevelViewController.m
//  Created by Felix Xiao
//

#import "LevelViewController.h"

//define values for scrollview and pagination
#define BUTTON_WIDTH 87
#define BUTTON_HEIGHT 117
#define BUTTON_PADDING 15
#define BUTTONS_PER_PAGE 15
#define PAGE_WIDTH ((BUTTON_WIDTH + BUTTON_PADDING) * BUTTONS_PER_PAGE)
#define MAGIC_BUTTON_TAG_OFFSET 6238 

@class Level;

@interface LevelViewController ()

@end

@implementation LevelViewController

//synthesize properties
@synthesize levelIdentifier = _levelIdentifier;
@synthesize gameLevel = _gameLevel;
@synthesize levelScroll = _levelScroll;
@synthesize percentDone = _percentDone;
@synthesize player = _player;
@synthesize hintsLabel = _hintsLabel;
@synthesize delegate = _delegate;
@synthesize scrollView;
@synthesize pageControl;
@synthesize allLevels = _allLevels;

//CALLS THE DELEGATE METHOD TO GO BACK TO THE MENU AND UPDATE ITS LABELS
- (IBAction)back:(id)sender
{
    self.player = [[[Player alloc] init] autorelease];
    [self.player loadProfile:self.player];
    [_delegate finishedDoingMyThing:self.percentDone.currentTitle withId:self.levelIdentifier andPlayer:self.player];
}

//INITIALIZES A LEVELVIEWCONTROLLER
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

//LOADS THE LEVEL
- (void)loadLevel:(Level*)level
{
     scrollView.delegate = self;
     
     [self.scrollView setBackgroundColor:[UIColor clearColor]];
     [scrollView setCanCancelContentTouches:NO];
     
     scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
     scrollView.clipsToBounds = YES;
     scrollView.scrollEnabled = YES;
     scrollView.pagingEnabled = YES;
     
     CGFloat cx = 0;
    
    //print out small versions of jerseys
    Jersey *tempJersey;
    for (int i = 0; i < level.levelJerseys.count; i++) {

        int i2 = i+1;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i2%6==1||i2%6==2||i2%6==3) { //position 1, 2, 3, row one
            btn.frame = CGRectMake((i%6) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
        } else { //position 4, 5, 6, row two
            btn.frame = CGRectMake((i%6-3) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx, (BUTTON_HEIGHT + BUTTON_PADDING + 20), BUTTON_WIDTH, BUTTON_HEIGHT);
        }
        btn.tag = i + MAGIC_BUTTON_TAG_OFFSET; // to relate to the array index
        
        tempJersey = [level.levelJerseys objectAtIndex:i];
        if (tempJersey.solved==NO && [tempJersey.currentGuess isEqualToString:@"None"]) { //not yet guessed
            [btn setBackgroundImage:tempJersey.image forState:UIControlStateNormal];
            [scrollView addSubview:btn];
            UIButton *statusImage = [UIButton buttonWithType:UIButtonTypeCustom];
            statusImage.tag = i;
            statusImage.enabled = NO;
            [statusImage setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateDisabled];
            if (i2%6==1||i2%6==2||i2%6==3) {
                statusImage.frame = CGRectMake((i%6) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx + (BUTTON_WIDTH/2)-12, BUTTON_HEIGHT,24,24);
            } else {
                statusImage.frame = CGRectMake((i%6-3) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx + (BUTTON_WIDTH/2)-12,(BUTTON_HEIGHT + BUTTON_PADDING + 20 + BUTTON_HEIGHT),24,24);
            }
            [scrollView addSubview:statusImage];
        } else if (tempJersey.solved==NO &&
                   ([self compareStrings:tempJersey.currentGuess and:tempJersey.printedName] ||
                    [self compareStrings:tempJersey.currentGuess and:tempJersey.fullName])) { //if the currentGuess is close
            [btn setBackgroundImage:tempJersey.image forState:UIControlStateNormal];
            [scrollView addSubview:btn];
                       
            UIButton *statusImage = [UIButton buttonWithType:UIButtonTypeCustom];
            statusImage.tag = i;
            statusImage.enabled = NO;
            [statusImage setBackgroundImage:[UIImage imageNamed:@"yellowcircle.png"] forState:UIControlStateDisabled];
            
            if (i2%6==1||i2%6==2||i2%6==3) {
                statusImage.frame = CGRectMake((i%6) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx + (BUTTON_WIDTH/2)-12, BUTTON_HEIGHT,24,24);
            } else {
                statusImage.frame = CGRectMake((i%6-3) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx + (BUTTON_WIDTH/2)-12,(BUTTON_HEIGHT + BUTTON_PADDING + 20 + BUTTON_HEIGHT),24,24);
            }
            [self.levelScroll addSubview:statusImage];
        } else if (tempJersey.solved==NO) { //guessed incorrectly already
            [btn setBackgroundImage:tempJersey.image forState:UIControlStateNormal];
            [scrollView addSubview:btn];
            
            UIButton *statusImage = [UIButton buttonWithType:UIButtonTypeCustom];
            statusImage.tag = i;
            statusImage.enabled = NO;
            [statusImage setBackgroundImage:[UIImage imageNamed:@"redcross.png"] forState:UIControlStateDisabled];
            
            if (i2%6==1||i2%6==2||i2%6==3) {
                statusImage.frame = CGRectMake((i%6) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx + (BUTTON_WIDTH/2)-12, BUTTON_HEIGHT,24,24);
            } else {
                statusImage.frame = CGRectMake((i%6-3) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx + (BUTTON_WIDTH/2)-12,(BUTTON_HEIGHT + BUTTON_PADDING + 20 + BUTTON_HEIGHT),24,24);
            }
            [scrollView addSubview:statusImage];
        } else { //already solved
            [btn setBackgroundImage:(UIImage*)[self convertImageToGrayScale:tempJersey.image] forState:UIControlStateNormal];
            [scrollView addSubview:btn];
            
            UIButton *statusImage = [UIButton buttonWithType:UIButtonTypeCustom];
            statusImage.tag = i;
            statusImage.enabled = NO;
            [statusImage setBackgroundImage:[UIImage imageNamed:@"greencheck.png"] forState:UIControlStateDisabled];
            
            if (i2%6==1||i2%6==2||i2%6==3) {
                statusImage.frame = CGRectMake((i%6) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx + (BUTTON_WIDTH/2)-12, BUTTON_HEIGHT,24,24);
            } else {
                statusImage.frame = CGRectMake((i%6-3) * (BUTTON_WIDTH + BUTTON_PADDING) + 5 + cx + (BUTTON_WIDTH/2)-12,(BUTTON_HEIGHT + BUTTON_PADDING + 20 + BUTTON_HEIGHT),24,24);
            }
            [scrollView addSubview:statusImage];
        }
         
        
        if ((i2%6==0)&&(i>0)) { cx += scrollView.frame.size.width;}
        
        [btn addTarget:self action:@selector(jerseyPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    self.pageControl.numberOfPages = (level.levelJerseys.count + 6 - 1)/6;
    [scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
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

//WHAT HAPPENS WHEN THE BUTTON IS PRESSED ON A JERSEY
- (void)jerseyPressed:(UIButton *)btn
{
    int index = btn.tag - MAGIC_BUTTON_TAG_OFFSET;
    Jersey *object = [self.gameLevel.levelJerseys objectAtIndex:index];
    
    [MTPopupWindow showWindowWithJersey:object insideView:self.view forLevel:self.gameLevel andScroll:scrollView andLevelsArray:self.allLevels];
    //[MTMiniPopupWindow showWindowWithTitle:@"Hints + 1" andMessage:@"You just scored another free hint!" alertID:@"newHint" insideView:self.view];
    [self.view bringSubviewToFront:adView];
}

//COMPARES TWO STRINGS AND RETURNS IF THEY ARE CLOSE
- (BOOL)compareStrings:(NSString*)string1 and:(NSString*)string2
{
    //put all the characters in both strings into 2 arrays
    NSMutableArray *string1Chars = [[NSMutableArray alloc] init];
    NSMutableArray *string2Chars = [[NSMutableArray alloc] init];
    
    int lettersInCommon = 0;
    for (int x = 0; x < [string1 length]; x++) {
        [string1Chars addObject:[string1 substringWithRange:NSMakeRange(x,1)]];
    }
    for (int x = 0; x < [string2 length]; x++) {
        [string2Chars addObject:[string2 substringWithRange:NSMakeRange(x,1)]];
    }
    
    //compare contents of 2 arrays
    for (NSString* string in string1Chars)
    {
        if([string2Chars containsObject:string]) {
            lettersInCommon = lettersInCommon + 1;
            [string2Chars removeObject:string];
        }
    }
    
    [string1Chars release];
    [string2Chars release];
    
    //if similarities are there, more than 75% of the same characters, return yes
    float f = 1.0f;
    f = f * lettersInCommon;
    f = f / [string2 length];
    
    if (f > 0.66) {
        return YES;
    } else {
        return NO;
    }
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

//LOADS THE VIEW CONTROLLER
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view bringSubviewToFront:adView];
    //set a view for the top bar
    CGRect topbarFrame = CGRectMake(0,0,321,70);
    UIView* topbarView = [[UIView alloc] initWithFrame:topbarFrame];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"topbar.png"]];
    topbarView.backgroundColor = background;
    [background release];
    [self.view addSubview:topbarView];
    [self.view sendSubviewToBack:topbarView];
    [topbarView release];
    
    self.player = [[[Player alloc] init] autorelease];
    [self.player loadProfile:self.player];

    self.gameLevel = [[[Level alloc] init] autorelease];
    [self.gameLevel createLevel:self.gameLevel withName:self.levelIdentifier]; 

    //load the top bar image
    CGRect nameFrame = CGRectMake(100,5,210,35);
    UIImageView *nameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topbarName.png"]];
    nameImageView.frame = nameFrame;
    [self.view addSubview:nameImageView];
    [nameImageView release];
    
    //load the top bar button for percent done
    CGRect percentFrame = CGRectMake(100,45,120,20);
    self.percentDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.percentDone.frame = percentFrame;
    self.percentDone.enabled = NO;
    [self.percentDone setTitle:[NSString stringWithFormat:@"%i%% complete", self.gameLevel.percentComplete] forState:UIControlStateDisabled];
    [self.percentDone setTag:-15];
    [self.percentDone setBackgroundImage:[UIImage imageNamed:@"percentBackground120.png"] forState:UIControlStateDisabled];
    [self.percentDone setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    self.percentDone.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [self.view addSubview:self.percentDone];
    
    //load the top bar label for hints
    CGRect hintsFrame = CGRectMake(230,45,80,20);
    self.hintsLabel = [[[UILabel alloc] initWithFrame:hintsFrame] autorelease];
    self.hintsLabel.text = [NSString stringWithFormat:@"Hints: %i", self.player.playerHints];
    self.hintsLabel.textAlignment = UITextAlignmentCenter;
    self.hintsLabel.tag = -101; //hintsLabel tag is -101
    self.hintsLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.hintsLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hintsBackground.png"]];
    [self.view addSubview:self.hintsLabel];
    
    //create a hidden uiimageview
    UIImageView *newHint = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newHint.png"]] autorelease];
    newHint.tag = 4646;
    newHint.hidden = YES;
    newHint.frame = CGRectMake(230,45,80,20);
    [self.view addSubview:newHint];
    [self.view bringSubviewToFront:newHint];
    
    [self loadLevel:self.gameLevel];
}

//UNLOADS THE VIEW CONTROLLER
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//SET ORIENTATION DEFAULTS
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation //complete
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
