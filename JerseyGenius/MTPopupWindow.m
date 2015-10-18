//
//  MTPopupWindow.m
//  Created by Felix Xiao
//

#import "AppDelegate.h"
#import "Player.h"
#import "MTPopupWindow.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define kShadeViewTag 1000

//define values for scrollview and pagination
#define MAGIC_BUTTON_TAG_OFFSET 6238
#define BUTTON_WIDTH 86.66
#define BUTTON_HEIGHT 117.25
#define BUTTON_PADDING 20
#define BUTTONS_PER_PAGE 15
#define PAGE_WIDTH ((BUTTON_WIDTH + BUTTON_PADDING) * BUTTONS_PER_PAGE)

@interface MTPopupWindow(Private)
- (id)initWithSuperview:(UIView*)sview andFile:(NSString*)fName;
@end

@implementation MTPopupWindow
{
    sqlite3 *DB_Jerseys;
    NSString *databasePath;
    NSString *docsDir;
    NSArray *dirPaths;
}

//declare static values for keyboard animation
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.2;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 105; //was 216
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

//synthesize properties
@synthesize popJersey = _popJersey;
@synthesize parentLevel = _parentLevel;
@synthesize player = _player;
@synthesize parentFull = _parentFull;
@synthesize parentView = _parentView;
@synthesize tap = _tap;

@synthesize guessTextField = _guessTextField;
@synthesize valueLabel = _valueLabel;
@synthesize checkButton = _checkButton;
@synthesize statusImage = _statusImage;

@synthesize solvedLabel = _solvedLabel;
@synthesize line1 = _line1;
@synthesize solvedLabel2 = _solvedLabel2;
@synthesize line2 = _line2;
@synthesize solvedLabel3 = _solvedLabel3;
@synthesize guessTab = _guessTab;
@synthesize hintsTab = _hintsTab;
@synthesize allLevels = _allLevels;

@synthesize click = _click;


//implement methods
//OVERRIDES WHAT HAPPENS WHEN A TEXTFIELD IS SELECTED, SHIFTS SCREEN UP TO ALLOW FOR KEYBOARD
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //create new gesture recognizer that dismisses the keyboard
    self.tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)] autorelease];
    [bigPanelView addGestureRecognizer:self.tap];
    
    textField.backgroundColor = nil; //clear the background color
    
    //code referenced later on to hide the keyboard
    CGRect textFieldRect = [bigPanelView.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [bigPanelView.window convertRect:bigPanelView.bounds fromView:bigPanelView];
    
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
    
    CGRect viewFrame = bigPanelView.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [bigPanelView setFrame:viewFrame];
    [UIView commitAnimations];
}

//OVERRIDES WHAT HAPPENS WHEN A TEXTFIELD IS CLOSED, SHIFTS SCREEN BACK DOWN
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = bigPanelView.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [bigPanelView setFrame:viewFrame];
    [bigPanelView removeGestureRecognizer:self.tap];
    [UIView commitAnimations];
}

//OVERRIDES WHAT HAPPENS WHEN A TEXTFIELD IS TYPED IN
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.backgroundColor = nil;
    return YES;
}

//DISMISSES THE KEYBOARD AND REMOVES THE GESTURE RECOGNIZER
- (void)dismissKeyboard
{
    if ([self.guessTextField isFirstResponder]) {
        [self.guessTextField resignFirstResponder];
        [bigPanelView removeGestureRecognizer:self.tap];
    }
}

//CREATES A NEW MTPOPUPWINDOW WITH A SPECIFIED JERSEY, VIEW, LEVEL, and SCROLLVIEW
+ (void)showWindowWithJersey:(Jersey*)selectedJersey insideView:(UIView*)view forLevel:(Level*)parentGameLevel andScroll:(UIScrollView*)scroll andLevelsArray: (NSMutableArray*)allLevels
{
    [[MTPopupWindow alloc] initWithSuperview:view andJersey:selectedJersey forLevel:parentGameLevel andScroll:scroll andLevelsArray:allLevels];
}

//INITIALIZES A NEW MTPOPUPWINDOW WITH A SPECIFIED VIEW, JERSEY, LEVEL, and SCROLLVIEW
- (id)initWithSuperview:(UIView*)sview andJersey:(Jersey*)jersey forLevel:(Level*)parentGameLevel andScroll:(UIScrollView*)scroll andLevelsArray:(NSMutableArray*)allLevels
{
    self = [super init];
    if (self) {
        //reload player data
        self.player = [[[Player alloc] init] autorelease];
        [self.player loadProfile:self.player];
        
        bgView = [[[UIView alloc] initWithFrame: sview.bounds] autorelease];
        [sview addSubview: bgView];
        
        //inherit from view controller that calls it
        self.parentFull = sview;
        _parentFull = sview;
        self.parentView = scroll;
        _parentView = scroll;
        self.parentLevel = parentGameLevel;
        _parentLevel = parentGameLevel;
        self.allLevels = allLevels;
        _allLevels = allLevels;
        
        [self performSelector:@selector(doTransitionWithContentFile:) withObject:jersey afterDelay:0.1];
    }
    return self;
}

//LOADS THE CREATED MTPOPUPWINDOW BASED ON THE JERSEY
- (void)doTransitionWithContentFile:(Jersey*)jersey
{
    self.popJersey = jersey;
    _popJersey = jersey;
    
    //faux view
    UIView* fauxView = [[[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)] autorelease];
    [bgView addSubview: fauxView];

    //the new panel
    bigPanelView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)] autorelease];
    bigPanelView.center = CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2);
    
    //add the window background
    UIImageView* background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popupWindowBack.png"]] autorelease];
    background.center = CGPointMake(bigPanelView.frame.size.width/2, bigPanelView.frame.size.height/2-20);
    [bigPanelView addSubview: background];
    
    //add buttons to alternate between guessing and viewing hints
    self.guessTab = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.guessTab setBackgroundImage:[UIImage imageNamed:@"guess.png"] forState:UIControlStateNormal];
    [self.guessTab setBackgroundImage:[UIImage imageNamed:@"guess.png"] forState:UIControlStateDisabled];
    [self.guessTab setFrame: CGRectMake(90,16,66,36)];
    [self.guessTab addTarget:self action:@selector(guessSelected) forControlEvents:UIControlEventTouchUpInside];
    [bigPanelView addSubview:self.guessTab];
    
    self.hintsTab = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hintsTab setBackgroundImage:[UIImage imageNamed:@"hints.png"] forState:UIControlStateNormal];
    [self.hintsTab setBackgroundImage:[UIImage imageNamed:@"hints.png"] forState:UIControlStateDisabled];
    [self.hintsTab setFrame: CGRectMake(164,16,66,36)];
    [self.hintsTab addTarget:self action:@selector(hintsSelected) forControlEvents:UIControlEventTouchUpInside];
    [bigPanelView addSubview:self.hintsTab];
    
    //draw picture of the selected jersey
    UIImageView* jerseyImage = [[[UIImageView alloc] initWithImage:self.popJersey.image] autorelease];
    jerseyImage.center = CGPointMake(bigPanelView.frame.size.width/2, bigPanelView.frame.size.height/2);
    jerseyImage.frame = CGRectMake(75,54,170,230);
    [bigPanelView addSubview: jerseyImage];
    
    [self guessSelected]; //by default, the guess tab is loaded
    
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

//LOADS THE VIEW WHEN THE GUESS SIDE IS BEING VIEWED
- (void)guessSelected
{
    //disable guess button because it is already selected, enable hints button
    [self.guessTab setEnabled:NO];
    [self.hintsTab setEnabled:YES];
    
    //remove all possible views from hints
    [self.solvedLabel removeFromSuperview];
    [self.solvedLabel2 removeFromSuperview];
    [self.solvedLabel3 removeFromSuperview];
    [self.checkButton removeFromSuperview];
    [self.statusImage removeFromSuperview];
    [self.line1 removeFromSuperview];
    [self.line2 removeFromSuperview];
    
    if (self.popJersey.solved==NO) //assuming that the jersey has not been solved
    {
        //load a text field for guessing
        self.guessTextField = [[[UITextField alloc] initWithFrame:CGRectMake(40, 287, 240, 35)] autorelease];
        self.guessTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.guessTextField.textAlignment = UITextAlignmentCenter;
        self.guessTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.guessTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.guessTextField.returnKeyType = UIReturnKeyGo;
        self.guessTextField.clearButtonMode = UITextFieldViewModeAlways;
        self.guessTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.guessTextField.delegate = self;
        self.guessTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        //additional setup of placeholder and current text
        if (![self.popJersey.currentGuess isEqualToString:@"None"]) { //if already guessed
            [self.guessTextField setText:self.popJersey.currentGuess];
            [self.guessTextField setPlaceholder:self.popJersey.currentGuess];
        } else {
            [self.guessTextField setPlaceholder:@"       Who do I belong to?"];
        }
        [bigPanelView addSubview:self.guessTextField];
        
        //add a check button
        self.checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.checkButton setFrame:CGRectMake(70, 330, 180, 45)];
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"checkguess.png"] forState:UIControlStateNormal];
        [self.checkButton addTarget:self action:@selector(checkGuessSelected) forControlEvents:UIControlEventTouchUpInside];
        [bigPanelView addSubview:self.checkButton];
        
        //add label that says how many points the jersey is worth
        NSString *tempString = @"Worth ";
        NSString *tempString2 = [NSString stringWithFormat:@"%d",self.popJersey.points];
        tempString = [tempString stringByAppendingString:tempString2];
        tempString = [tempString stringByAppendingString:@" Points"];
        CGRect labelFrame = CGRectMake(80,375,160,30);
        self.valueLabel = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
        self.valueLabel.backgroundColor = [UIColor clearColor];
        self.valueLabel.text = tempString;
        self.valueLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.valueLabel.textAlignment = UITextAlignmentCenter;
        [bigPanelView addSubview:self.valueLabel];
        
     }
    else //assuming that the jersey has already been solved
    {
        //create label that shows the full name of the player
        CGRect labelFrame = CGRectMake(40,280,240,25);
        self.solvedLabel = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
        self.solvedLabel.textColor = UIColor.whiteColor;
        self.solvedLabel.backgroundColor = UIColor.clearColor;
        self.solvedLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        self.solvedLabel.text = self.popJersey.fullName;
        self.solvedLabel.textAlignment = UITextAlignmentCenter;
        [bigPanelView addSubview:self.solvedLabel];
        
        //create label that shows the team name of the player
        CGRect labelFrame2 = CGRectMake(40,310,240,25);
        self.solvedLabel2 = [[[UILabel alloc] initWithFrame:labelFrame2] autorelease];
        self.solvedLabel2.textColor = UIColor.greenColor;
        NSString *tempString = @"";
        tempString = [tempString stringByAppendingString:self.popJersey.city];
        tempString = [tempString stringByAppendingString:@" "];
        tempString = [tempString stringByAppendingString:self.popJersey.mascot];
        self.solvedLabel2.text = tempString;
        self.solvedLabel2.font = [UIFont boldSystemFontOfSize:17.0f];
        self.solvedLabel2.backgroundColor = UIColor.clearColor;
        self.solvedLabel2.textAlignment = UITextAlignmentCenter;
        self.solvedLabel2.textColor = UIColor.blackColor;
        [bigPanelView addSubview:self.solvedLabel2];
        
        //create image of a checkmark
        self.statusImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greencheck.png"]] autorelease];
        self.statusImage.center = CGPointMake(160, 350);
        [bigPanelView addSubview:self.statusImage];
     }

}

//PLAYS A SOUND AFTER A CORRECT GUESS
- (void)playClick
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"correct" ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    self.click = [[[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil] autorelease];
    [self.click play];
}

//CHECKS A SUBMITTED GUESS AND UPDATES APP ACCORDINGLY
- (NSString*)checkGuessSelected
{
    if (self.guessTextField.text==nil) { return @"EMPTY"; } //assuming the textfield has not been touched and contains nothing
    
    NSString *tempString = [[[NSString alloc] initWithString:[self.popJersey checkGuess:self.guessTextField.text]] autorelease];
    
    if ([tempString isEqualToString:@"YES"]) //if the guess is correct
    {
        [self.guessTextField setBackgroundColor:[UIColor greenColor]]; //set background of textfield to green
        if (self.player.sound==YES){ 
            if (![[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) {
            [self playClick];
            }
        } //play a sound if sound is on
        //add a hint for every 250 points earned
        int oldDivideBy250 = self.player.playerPoints/250;
        int newDivideBy250 = (self.player.playerPoints+self.popJersey.points)/250;
        if (newDivideBy250 > oldDivideBy250) //if a new hint is earned
        {
            [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints + 1)];
            //auto update hints
            for (UILabel* label in self.parentFull.subviews) {
                if (label.tag==-101) {
                    [label setText:[NSString stringWithFormat:@"Hints: %i", (self.player.playerHints+1)]];
                }
            }
            
            for (UIImageView *imageView in self.parentFull.subviews) {
                if (imageView.tag==4646) {
                    imageView.hidden = NO;
                    imageView.alpha = 1.0f;
                    
                    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
                    [UIView animateWithDuration:0.5 delay:2.0 options:0 animations:^{
                        // Animate the alpha value of your imageView from 1.0 to 0.0 here
                        imageView.alpha = 0.0f;
                    } completion:^(BOOL finished) {
                        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
                        imageView.hidden = YES;
                    }];
                    
                    
                    
                }
            }
            
            
            
            
            //[MTMiniPopupWindow showWindowWithTitle:@"Hints + 1" andMessage:@"You just scored another free hint!" alertID:@"newHint" insideView:self.view];
        }
        
        //check to see if a new level has been unlocked, show alert if it has
        if (self.parentLevel.numberSolved==14) { //about to solve a new one
            int levelNumber = [[self.parentLevel.levelName substringToIndex:1] integerValue];
            NSString *secondPart = [self.parentLevel.levelName substringFromIndex:1];
            NSString *identifierTwo = [NSString stringWithFormat:@"%i",levelNumber+1];
            identifierTwo = [identifierTwo stringByAppendingString:secondPart];
            
            if ([self.allLevels containsObject:identifierTwo]) { //if a higher level does exist
                //show an alert
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Great work!"
                                                                  message:@"You've completed 50% of this level! Return to the main title screen to unlock a new level."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Continue"
                                                        otherButtonTitles:nil];
                [message show];
                [message release];
                
                //delegate with 
                
            }
            
        }
        
        
        [self.player updateProfile:self.player inField:@"profilePoints" toNew:nil ifInt:(self.player.playerPoints+self.popJersey.points)]; //-1
        self.player.playerPoints = self.player.playerPoints + self.popJersey.points;
        
        //change the specific jersey to have grayscale and checkmark, add green checkmark
        for (UIButton* button in self.parentView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                if (([button tag]-MAGIC_BUTTON_TAG_OFFSET) == [self.parentLevel.levelJerseys indexOfObject:self.popJersey]) {
                    [button setBackgroundImage:(UIImage*)[self convertImageToGrayScale:self.popJersey.image] forState:UIControlStateNormal];
                } else if ([button tag]==[self.parentLevel.levelJerseys indexOfObject:self.popJersey]) {
                    [button setBackgroundImage:[UIImage imageNamed:@"greencheck.png"] forState:UIControlStateDisabled];
                }
            }
        }
        
        //update the percent complete
        for (UIButton* label in self.parentFull.subviews) {
            if (label.tag==-15) {
                [label setTitle:@"" forState:UIControlStateDisabled];
                int newPercent = ((self.parentLevel.numberSolved +1)*100)/[self.parentLevel.levelJerseys count];
                self.parentLevel.numberSolved++;
                [label setTitle:[NSString stringWithFormat:@"%i%% complete", newPercent] forState:UIControlStateDisabled];
            }
        }
        
        [self closePopupWindow];
        return @"YES";
    }
    else if ([tempString isEqualToString:@"NO"]) //if the guess is incorrect
    { 
        for (UIButton* button in self.parentView.subviews) { //add a red cross
            if ([button isKindOfClass:[UIButton class]]) {
                if ([button tag]==[self.parentLevel.levelJerseys indexOfObject:self.popJersey]) {
                    [button setBackgroundImage:[UIImage imageNamed:@"redcross.png"] forState:UIControlStateDisabled];
                }
            }
        }
        [self.guessTextField setBackgroundColor:[UIColor redColor]]; //set background of text field to red
        NSString *tempString = @"Worth ";
        NSString *tempString2 = [NSString stringWithFormat:@"%d",self.popJersey.points];
        tempString = [tempString stringByAppendingString:tempString2];
        tempString = [tempString stringByAppendingString:@" Points"];
        self.valueLabel.text = tempString;
        return @"NO";
    }
    else if ([tempString isEqualToString:@"CLOSE"]) //if the guess is close
    {
        for (UIButton* button in self.parentView.subviews) { //add a yellow circle
            if ([button isKindOfClass:[UIButton class]]) {
                if ([button tag]==[self.parentLevel.levelJerseys indexOfObject:self.popJersey]) {
                    [button setBackgroundImage:[UIImage imageNamed:@"yellowcircle.png"] forState:UIControlStateDisabled];
                }
            }
        }
        [self.guessTextField setBackgroundColor:[UIColor yellowColor]]; //set the text field background to yellow
        NSString *tempString = @"Worth ";
        NSString *tempString2 = [NSString stringWithFormat:@"%d",self.popJersey.points];
        tempString = [tempString stringByAppendingString:tempString2];
        tempString = [tempString stringByAppendingString:@" Points"];
        self.valueLabel.text = tempString;
        return @"CLOSE";
    }
    return nil;
}

//CONVERTS AN IMAGE TO A GRAYSCALE VERSION
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
}

//LOADS THE VIEW WHEN THE HINTS SIDE IS BEING VIEWED
- (void)hintsSelected
{
    //disable the hints button because it's already selected, enable the guess button
    [self.guessTab setEnabled:YES];
    [self.hintsTab setEnabled:NO];
    
    //remove everything that the guess side could have contained
    [self.guessTextField removeFromSuperview];
    [self.valueLabel removeFromSuperview];
    [self.checkButton removeFromSuperview];
    [self.solvedLabel removeFromSuperview];
    [self.line1 removeFromSuperview];
    [self.solvedLabel2 removeFromSuperview];
    [self.line2 removeFromSuperview];
    [self.solvedLabel3 removeFromSuperview];
    [self.statusImage removeFromSuperview];
    
    //create the first hint label
    CGRect labelFrame = CGRectMake(20,290,280,30);
    self.solvedLabel = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
    self.solvedLabel.textColor = UIColor.whiteColor;
    self.solvedLabel.textAlignment = UITextAlignmentCenter;
    self.solvedLabel.numberOfLines = 2;
    self.solvedLabel.font=[self.solvedLabel.font fontWithSize:12.5];
    self.solvedLabel.backgroundColor = [UIColor clearColor];
    
    //create the second hint label
    CGRect labelFrame2 = CGRectMake(20,325,280,30);
    self.solvedLabel2 = [[[UILabel alloc] initWithFrame:labelFrame2] autorelease];
    self.solvedLabel2.textColor = UIColor.whiteColor;
    self.solvedLabel2.textAlignment = UITextAlignmentCenter;
    self.solvedLabel2.numberOfLines = 2;
    self.solvedLabel2.font=[self.solvedLabel2.font fontWithSize:12.5];
    self.solvedLabel2.backgroundColor = [UIColor clearColor];
    
    //create the third hint label
    CGRect labelFrame3 = CGRectMake(20,360,280,30);
    self.solvedLabel3 = [[[UILabel alloc] initWithFrame:labelFrame3] autorelease];
    self.solvedLabel3.textColor = UIColor.whiteColor;
    self.solvedLabel3.textAlignment = UITextAlignmentCenter;
    self.solvedLabel3.numberOfLines = 2;
    self.solvedLabel3.font=[self.solvedLabel3.font fontWithSize:12.5];
    self.solvedLabel3.backgroundColor = [UIColor clearColor];
    
    //create two separator lines
    self.line1 = [[[UIView alloc] initWithFrame:CGRectMake(25, 321, 270, 2)] autorelease];
    self.line1.backgroundColor = [UIColor blackColor];
    self.line2 = [[[UIView alloc] initWithFrame:CGRectMake(25, 356, 270, 2)] autorelease];
    self.line2.backgroundColor = [UIColor blackColor];
    
    //clear all current labels
    [self.solvedLabel setText:@""];
    [self.solvedLabel2 setText:@""];
    [self.solvedLabel3 setText:@""];
    [self.valueLabel setText:@""];
    
    if (!self.popJersey.solved) //scenarios for showing hints if not solved
    {
        if (self.popJersey.hint1Show) { //HINT 1 SCENARIOS
            [self.solvedLabel setText:self.popJersey.hint1];
            if (self.popJersey.hint2Show) { //HINT 1+2
                [bigPanelView addSubview:self.line1];
                [self.solvedLabel2 setText:self.popJersey.hint2];
                if (self.popJersey.hint3Show) { //HINT 1+2+3
                    [bigPanelView addSubview:self.line2];
                    [self.solvedLabel3 setText:self.popJersey.hint3];
                }
            } else if (self.popJersey.hint3Show) { //HINT 1+3
                [bigPanelView addSubview:self.line1];
                [self.solvedLabel2 setText:self.popJersey.hint3];
            }
        } else if (self.popJersey.hint2Show) { //HINT 2 SCENARIOS
            [self.solvedLabel setText:self.popJersey.hint2];
            if (self.popJersey.hint3Show) { //HINT 2+3
                [bigPanelView addSubview:self.line1];
                [self.solvedLabel2 setText:self.popJersey.hint3];
            }
        } else if (self.popJersey.hint3Show) { //HINT 3 SCENARIOS
            [self.solvedLabel setText:self.popJersey.hint3]; 
        }
    }
    else { //show all 3 if solved
        [self.solvedLabel setText:self.popJersey.hint1];
        [bigPanelView addSubview:self.line1];
        [self.solvedLabel2 setText:self.popJersey.hint2];
        [bigPanelView addSubview:self.line2];
        [self.solvedLabel3 setText:self.popJersey.hint3];
    }
    
    //add labels to view
    [bigPanelView addSubview:self.solvedLabel];
    [bigPanelView addSubview:self.solvedLabel2];
    [bigPanelView addSubview:self.solvedLabel3];
    
    //show a "Show a Hint button" if not all have been shown and not solved yet
    if (!self.popJersey.solved&&(!self.popJersey.hint1Show || !self.popJersey.hint2Show || !self.popJersey.hint3Show)) {
        self.checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.checkButton setFrame:CGRectMake(70, 360, 180, 45)];
        [self.checkButton addTarget:self action:@selector(showRandomHint) forControlEvents:UIControlEventTouchUpInside];
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"showhint.png"] forState:UIControlStateNormal];
        [bigPanelView addSubview:self.checkButton];
    }
    if (self.popJersey.solved) {
        self.statusImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greencheck.png"]] autorelease];
        self.statusImage.center = CGPointMake(160, 395);
        [bigPanelView addSubview:self.statusImage];
    }
}

//GET A RANDOM NUMBER BETWEEN X AND Y
- (int)getRandomNumber:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

//SHOW A RANDOM HINT AFTER THE SHOW HINT BUTTON IS PRESSED
- (void)showRandomHint
{
    if (self.player.playerHints>0) //assuming hints are still available
    {
        //count number of hints still unshown by number of labels that aren't empty
        int counter = 0;
        if ([self.solvedLabel.text isEqualToString:@""]) { counter = counter + 1; }
        if ([self.solvedLabel2.text isEqualToString:@""]) { counter = counter + 1; }
        if ([self.solvedLabel3.text isEqualToString:@""]) { counter = counter + 1; }
        int temp;
        
        if (counter==1) //if one hint is left, show it
        {
            if (!self.popJersey.hint1Show) {
                [self.popJersey showHint1];
                [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                self.player.playerHints = self.player.playerHints - 1;
            }
            else if (!self.popJersey.hint2Show) {
                [self.popJersey showHint2];
                [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                self.player.playerHints = self.player.playerHints - 1;
            }
            else if (!self.popJersey.hint3Show) {
                [self.popJersey showHint3];
                [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                self.player.playerHints = self.player.playerHints - 1;
            }
        }
        else if (counter==2) //if two hints are left
        { 
            temp = [self getRandomNumber:1 to:2];
            if (![self.solvedLabel.text isEqualToString:@""]) { //if hint 1 is already shown, choose random between 2 and 3
                if (temp==1) {
                    [self.popJersey showHint2];
                    [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                    self.player.playerHints = self.player.playerHints - 1;
                }
                else if (temp==2) {
                    [self.popJersey showHint3];
                    [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                    self.player.playerHints = self.player.playerHints - 1;
                }
            } else if (![self.solvedLabel2.text isEqualToString:@""]) { //if hint 2 is already shown, choose random between 1 and 3
                if (temp==1) {
                    [self.popJersey showHint1];
                    [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                    self.player.playerHints = self.player.playerHints - 1;
                }
                else if (temp==2) {
                    [self.popJersey showHint3];
                    [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                    self.player.playerHints = self.player.playerHints - 1;
                }
            } else if (![self.solvedLabel3.text isEqualToString:@""]) { //if hint 3 is already shown, choose random between 1 and 2
                if (temp==1) {
                    [self.popJersey showHint1];
                    [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                    self.player.playerHints = self.player.playerHints - 1;
                }
                else if (temp==2) {
                    [self.popJersey showHint2];
                    [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                    self.player.playerHints = self.player.playerHints - 1;
                }
            }
        }
        else if (counter==3) //if three hints are left
        {
            temp = [self getRandomNumber:1 to:3];
            if (temp==1) {
                [self.popJersey showHint1];
                [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                self.player.playerHints = self.player.playerHints - 1;
            }
            else if (temp==2) {
                [self.popJersey showHint2];
                [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                self.player.playerHints = self.player.playerHints - 1;
            }
            else if (temp==3) {
                [self.popJersey showHint3];
                [self.player updateProfile:self.player inField:@"profileHints" toNew:nil ifInt:(self.player.playerHints-1)]; //-1
                self.player.playerHints = self.player.playerHints - 1;
            }
        }
        
        //auto update hints label
        for (UILabel* label in self.parentFull.subviews) {
            if (label.tag==-101) {
                [label setText:[NSString stringWithFormat:@"Hints: %i", self.player.playerHints]];
            }
        }
        [self hintsSelected]; //reload the hints tab
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No more hints!"
                                                          message:@"You've ran out of hints! Earn 1 hint for every 250 points earned or buy more from the main menu!"
                                                         delegate:self
                                                cancelButtonTitle:@"Back"
                                                otherButtonTitles:nil];
        //[message addButtonWithTitle:@"Buy Hints"];
        [message show];
        [message release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    //if([title isEqualToString:@"Buy Hints"])
    //{
     //   //go to other menu page
   // }
    
}

//DETERMINES WHAT HAPPENS WHEN THE GO BUTTON IS PRESSED ON THE KEYBOARD
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == self.guessTextField) {
        if ([[self checkGuessSelected] isEqualToString:@"YES"]) {
            [self.guessTextField resignFirstResponder];
        }
    }
    return YES;
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
        
        //[MTMiniPopupWindow showWindowWithTitle:@"Hints + 1" andMessage:@"You just scored another free hint!" alertID:@"newHint" insideView:self.view];
        [self release];
    }];
}

@end