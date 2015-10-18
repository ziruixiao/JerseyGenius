//
//  Player.m
//  Created by Felix Xiao
//

#import "Player.h"

@implementation Player
{
    sqlite3 *DB_Jerseys;
    NSString *databasePath;
    NSString *docsDir;
    NSArray *dirPaths;
}

//synthesize properties
@synthesize playerName = _playerName;
@synthesize playerHints = _playerHints;
@synthesize playerTime = _playerTime;
@synthesize playerPoints = _playerPoints;
@synthesize sound = _sound;

//implement methods
//LOADS THE ACTIVE PROFILE FROM THE PROFILES TABLE IN THE DATABASE
- (void)loadProfile:(Player*)profile
{
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"DB_Jerseys.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open_v2(dbpath, &DB_Jerseys, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        
        NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM profiles ORDER BY profileTime DESC LIMIT 1"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(DB_Jerseys, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            NSString *temp = @"";
            while (sqlite3_step(statement) == SQLITE_ROW) {
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                profile.playerName = temp;
                [temp release];

                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                profile.playerPoints = [temp integerValue];
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                profile.playerHints = [temp integerValue];
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                profile.playerTime = [temp integerValue];
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                if ([temp integerValue]==0) { profile.sound = NO; }
                if ([temp integerValue]==1) { profile.sound = YES; }
                [temp release];
            }
            
        } else {
            NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys));
        }
    } else {
        NSLog(@"something went really wrong");
    }
    //load the playerName from Game Center if connected
    [databasePath release];
}

//UPDATES THE ACTIVE PROFILE WITH A SPECIFIED FIELD, STRING VALUE, AND INTEGER VALUE
- (BOOL)updateProfile:(Player*)player inField:(NSString*)field toNew:(NSString*)newValue ifInt:(int)integer //complete
{
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"DB_Jerseys.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    NSString *querySQL = @"";
    const char *query_stmt;
    
    if (sqlite3_open_v2(dbpath, &DB_Jerseys, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        if ([newValue isKindOfClass:[NSString class]]) { //an NSString
            querySQL = [NSString stringWithFormat: @"UPDATE profiles SET \%@=\"%@\" WHERE profileName=\"%@\"", field, newValue, player.playerName];
        } else if (integer>=0) { //an int or bool value, not a string to use
            querySQL = [NSString stringWithFormat: @"UPDATE profiles SET \%@=\"%i\" WHERE profileName=\"%@\"", field, integer, player.playerName];
        } else {}
        
        query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(DB_Jerseys, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                return YES;
            }else {
                NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys));
                return NO;
            }
        } else {
            NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys));
            return NO;
        }
        sqlite3_finalize(statement);
    } else {
        return NO;
    }
    sqlite3_close(DB_Jerseys);
    [databasePath release];
}

//ADD ANOTHER PROFILE, CURRENTLY EMPTY FUNCTION
- (void)addProfile
{
    
}

@end
