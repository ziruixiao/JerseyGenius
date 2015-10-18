//
//  ScrollingAppDelegate.m
//  Scrolling
//
//  Created by David Janes on 09-09-25.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ScrollingAppDelegate.h"
#import "MenuViewController.h"
#import "LevelViewController.h"

@implementation ScrollingAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window makeKeyAndVisible];
}


- (void)dealloc {
    //[viewController release];
    [window release];
    [super dealloc];
}


@end
