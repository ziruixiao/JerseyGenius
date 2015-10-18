//
//  main.m
//  JerseyGenius
//
//  Created by Felix Xiao on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jersey.h"
#import "AppDelegate.h"
#import <sqlite3.h>
#import "Level.h"
#import "Player.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        //Jersey *test = [[Jersey alloc] init];
        //[test createJersey:test withName:@"Tony Romo"]; //currently works!
        
        //[test updateJersey:test inField:@"points" toNew:nil ifInt:100];
        //[test updateJersey:test inField:@"city" toNew:@"Dallas" ifInt:-1];
        
        //Level *nfl1 = [[Level alloc] init];
        //[nfl1 resetGame];
        //[nfl1 createLevel:nfl1 withName:@"1NBA"];
        
        //Player *newPlayer = [[Player alloc] init];
        //[newPlayer loadProfile:newPlayer];
        
        /*
        NSString *newString = @"98 percent complete";
        NSString *secondString = @"";
        
        for (int x = 0; x < newString.length; x++) {
            if ([[newString substringWithRange:NSMakeRange(x,1)] isEqualToString:@" "]) {
                break;
            }
            secondString = [secondString stringByAppendingString:[newString substringWithRange:NSMakeRange(x,1)]];
            NSLog(@"itemadded:%@",[newString substringWithRange:NSMakeRange(x,1)]);
        }
       int newInt = [secondString intValue];
       NSLog(@"%i",newInt);
         */
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
