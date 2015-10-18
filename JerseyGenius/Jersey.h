//
//  Jersey.h
//  Created by Felix Xiao
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Player.h"

@interface Jersey : NSObject

//declare properties
@property (nonatomic, readwrite) NSInteger jerseyID; //just a basic ID number for the jersey
@property (nonatomic, copy, readwrite) NSString *level; //the level that the jersey shows up in
@property BOOL active; //whether or not the jersey is active
@property (nonatomic, copy, readwrite) NSString *printedName; //what is printed on the back of the jersey
@property (nonatomic, copy, readwrite) NSString *fullName; //the player's full name
@property (nonatomic, readwrite) NSInteger number; //the jersey's printed number
@property (nonatomic, copy, readwrite) NSString *sport; //the sport the jersey belongs to
@property (nonatomic, copy, readwrite) NSString *city; //the city the team belongs to
@property (nonatomic, copy, readwrite) NSString *mascot; //the team mascot
@property (nonatomic, copy, readwrite) NSString *hint1; //first text hint
@property BOOL hint1Show; //whether to show the first hint
@property (nonatomic, copy, readwrite) NSString *hint2; //second text hint
@property BOOL hint2Show; //whether to show the second hint
@property (nonatomic, copy, readwrite) NSString *hint3; //third text hint
@property BOOL hint3Show; //whether to show the third hint
@property BOOL solved; //whether the jersey has been solved
@property NSInteger points; //amount of points awarded when solved
@property (nonatomic, copy, readwrite) NSString *currentGuess; //current guess for the jersey
@property (nonatomic, copy, readwrite) UIImage *image; //URL location for the jersey

//declare methods
- (void)createJersey:(Jersey*)newJersey withName:(NSString*)playerName;
- (BOOL)updateJersey:(Jersey*)jersey inField:(NSString*)field toNew:(NSString*)newValue ifInt:(int)integer;
- (void)showHint1;
- (void)showHint2;
- (void)showHint3;
- (BOOL)compareStrings:(NSString*)string1 and:(NSString*)string2;
- (NSString*)checkGuess:(NSString*)guess;

@end
