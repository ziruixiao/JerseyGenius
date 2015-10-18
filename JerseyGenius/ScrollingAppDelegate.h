//
//  ScrollingAppDelegate.h
//  Scrolling
//
//  Created by David Janes on 09-09-25.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "LevelViewController.h"

@class MenuViewController;
@class LevelViewController;

@interface ScrollingAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

