//
//  Level.h
//  Created by Felix Xiao
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Jersey.h"
#import "Player.h"

@class Jersey;

@interface Level : NSObject

//declare properties
@property (nonatomic, copy, readwrite) NSString *levelName;
@property (nonatomic, retain, readwrite) NSMutableArray *levelJerseys;
@property BOOL levelUnlocked;
@property (nonatomic, retain, readwrite) NSMutableArray *levelPlayers;
@property int percentComplete;
@property int numberSolved;
@property int prevLevelSolved;

//declare methods
- (void)createLevel:(Level*)newLevel withName:(NSString*)levelIdentifier;
- (void)resetGame;
- (int)getRandomNumber:(int)from to:(int)to;

@end
