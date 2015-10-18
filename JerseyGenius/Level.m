//
//  Level.m
//  Created by Felix Xiao
//

#import "Level.h"
@implementation Level
{
    sqlite3 *DB_Jerseys;
    NSString *databasePath;
    NSString *docsDir;
    NSArray *dirPaths;
}

//synthesize properties
@synthesize levelName = _levelName;
@synthesize levelJerseys = _levelJerseys;
@synthesize levelUnlocked = _levelUnlocked;
@synthesize levelPlayers = _levelPlayers;
@synthesize percentComplete = _percentComplete;
@synthesize numberSolved = _numberSolved;
@synthesize prevLevelSolved = _prevLevelSolved;

//implement methods
//INITIALIZES A LEVEL
- (id)init
{
    self = [super init];
    if (self) {
        // Initialize self.
    }
    return self;
}

//CREATES A LEVEL GIVEN THE LEVEL IDENTIFIER
- (void)createLevel:(Level*)newLevel withName:(NSString*)levelIdentifier
{
    //connect to the database
    newLevel.levelName = levelIdentifier;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"DB_Jerseys.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    //create a second level identifier if needed
    int levelNumber = [[levelIdentifier substringToIndex:1] integerValue];
    NSString *secondPart = [levelIdentifier substringFromIndex:1];
    NSString *identifierTwo = [NSString stringWithFormat:@"%i",levelNumber-1];
    identifierTwo = [identifierTwo stringByAppendingString:secondPart];
    
    if (sqlite3_open_v2(dbpath, &DB_Jerseys, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        //STEP ONE: Fill levelPlayers MutableArray with fullName of all players matching levelIdentifier
        //STEP TWO: Fill levelJerseys MutableArray with jerseys of all players matching levelIdentifier
        NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM jerseys WHERE level=\"%@\" OR level=\"%@\"", levelIdentifier,identifierTwo];
        const char *query_stmt = [querySQL UTF8String];
        newLevel.prevLevelSolved = 0;
        if (sqlite3_prepare_v2(DB_Jerseys, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            NSString *temp = @"";
            newLevel.levelPlayers = [[[NSMutableArray alloc] init] autorelease];
            newLevel.levelJerseys = [[[NSMutableArray alloc] init] autorelease];
            NSMutableArray *yesJerseys = [[NSMutableArray alloc] init];
            NSMutableArray *noJerseys = [[NSMutableArray alloc] init];
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                  
                if ([temp isEqualToString:levelIdentifier]) {
                    temp = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] autorelease];
                    Jersey *tempJersey = [[[Jersey alloc] init] autorelease];
                    [tempJersey createJersey:tempJersey withName:temp];
                    if (tempJersey.solved==YES) { [yesJerseys addObject:tempJersey];}
                    if (tempJersey.solved==NO) { [noJerseys addObject:tempJersey];}
                }
                    
                if ([temp isEqualToString:identifierTwo]) { //a jersey in the level before has been solved
                    
                    temp = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 15)] autorelease];
                    if ([temp integerValue]==1) {
                        newLevel.prevLevelSolved = newLevel.prevLevelSolved + 1;
                    }
                }
                if (levelNumber==1) {
                    newLevel.prevLevelSolved = 30;
                }
            }
            
            int randomnum = 0;
            int numleft = 0;
            numleft = [noJerseys count];
            int hardcount = [noJerseys count];
            for (int x = 0; x < hardcount; x++ ) { //loop that runs through array of all unsolved jerseys
                randomnum = [self getRandomNumber:0 to:(numleft-1)];
                [newLevel.levelJerseys addObject:[noJerseys objectAtIndex:randomnum]];
                [newLevel.levelPlayers addObject:((Jersey*)[noJerseys objectAtIndex:randomnum]).fullName];
                [noJerseys removeObjectAtIndex:randomnum];
                numleft = numleft - 1;
            }
            
            randomnum = 0;
            numleft = 0;
            newLevel.numberSolved = 0;
            numleft = [yesJerseys count];
            hardcount = [yesJerseys count];
            for (int x = 0; x < hardcount; x++ ) { //loop that runs through array of all solved jerseys
                randomnum = [self getRandomNumber:0 to:(numleft-1)];
                [newLevel.levelJerseys addObject:[yesJerseys objectAtIndex:randomnum]];
                [newLevel.levelPlayers addObject:((Jersey*)[yesJerseys objectAtIndex:randomnum]).fullName];
                [yesJerseys removeObjectAtIndex:randomnum];
                numleft = numleft - 1;
                newLevel.numberSolved = newLevel.numberSolved + 1;
            }

            

            //set percentage of level complete
            int numSolved = 0; 
            int percentage = 100;
            Jersey* tempJersey2;
            for (int x = 0; x < newLevel.levelJerseys.count; x++) {
                tempJersey2 = [newLevel.levelJerseys objectAtIndex:x];
                if (tempJersey2.solved) {
                    numSolved = numSolved + 1;
                }
            }
            percentage = percentage * numSolved;
            percentage = percentage / (newLevel.levelJerseys.count);
            newLevel.percentComplete = percentage;
            
            [yesJerseys release];
            [noJerseys release];
            
        } else {
            NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys));
        }
        
    } else {
        NSLog(@"something went really wrong");
    }
    [databasePath release];
}

//GETS A RANDOM NUMBER FROM X TO Y
- (int)getRandomNumber:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

//RESETS GAME TO WHERE ALL GUESSES GO AWAY, ALL JERSEYS ARE NOT SOLVED, ALL HINTS ARE NOT SHOWN, ALL POINTS ARE 100
- (void)resetGame
{
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"DB_Jerseys.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    NSString *querySQL;
    const char *query_stmt;
    
    if (sqlite3_open_v2(dbpath, &DB_Jerseys, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        querySQL = [NSString stringWithFormat: @"UPDATE jerseys SET solved='0',currentGuess='None',points='100',hint1Show='0',hint2Show='0',hint3Show='0'"];
        
        query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(DB_Jerseys, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE) {
            }else {
                NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys));
            }
        } else {
            NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys));
        }
        sqlite3_finalize(statement);
    } else {
    }
    sqlite3_close(DB_Jerseys);
    [databasePath release];
}

@end
