//
//  Player.h
//  Created by Felix Xiao
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Jersey.h"
#import "Level.h"


@interface Player : NSObject

//declare properties
@property (retain, nonatomic, readwrite) NSString *playerName;
@property NSInteger playerHints;
@property NSInteger playerTime;
@property NSInteger playerPoints;
@property BOOL sound;

//declare methods
- (void)loadProfile:(Player*)profile;
- (BOOL)updateProfile:(Player*)player inField:(NSString*)field toNew:(NSString*)newValue ifInt:(int)integer;
- (void)addProfile;

@end
