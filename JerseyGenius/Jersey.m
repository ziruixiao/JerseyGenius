//
//  Jersey.m
//  Created by Felix Xiao
//

#import "Jersey.h"
#import <sqlite3.h>

@implementation Jersey
{
    sqlite3 *DB_Jerseys;
    NSString *databasePath;
    NSString *docsDir;
    NSArray *dirPaths;
}

//synthesize properties
@synthesize jerseyID = _jerseyID;
@synthesize level = _level;
@synthesize active = _active;
@synthesize printedName = _printedName;
@synthesize fullName = _fullName;
@synthesize number = _number;
@synthesize sport = _sport;
@synthesize city = _city;
@synthesize mascot = _mascot;
@synthesize hint1 = _hint1;
@synthesize hint1Show = _hint1Show;
@synthesize hint2 = _hint2;
@synthesize hint2Show = _hint2Show;
@synthesize hint3 = _hint3;
@synthesize hint3Show = _hint3Show;
@synthesize solved = _solved;
@synthesize points = _points;
@synthesize currentGuess = _currentGuess;
@synthesize image = _image;

//implement methods
//INITIALIZES THE CLASS
- (id)init
{
    self = [super init];
    if (self) {
        // Initialize self.
    }
    return self;
}

//CREATES THE SPECIFIED JERSEY FROM THE DATABASE
- (void)createJersey:(Jersey*)newJersey withName:(NSString*)playerName
{
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"DB_Jerseys.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open_v2(dbpath, &DB_Jerseys, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM jerseys WHERE fullName=\"%@\"", playerName];
            
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(DB_Jerseys, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *temp;
                //create jersey and assign properties
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                newJersey.jerseyID = [temp integerValue];
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                newJersey.level = temp;
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                if ([temp integerValue]==0) { newJersey.active = NO; }
                if ([temp integerValue]==1) { newJersey.active = YES; }
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                newJersey.printedName = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                newJersey.fullName = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                newJersey.number = [temp integerValue];
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                newJersey.sport = temp;
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)];
                newJersey.city = temp;
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)];
                newJersey.mascot = temp;
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)];
                newJersey.hint1 = temp;
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)];
                if ([temp integerValue]==0) { newJersey.hint1Show = NO; }
                if ([temp integerValue]==1) { newJersey.hint1Show = YES; }
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)];
                newJersey.hint2 = temp;
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)];
                if ([temp integerValue]==0) { newJersey.hint2Show = NO; }
                if ([temp integerValue]==1) { newJersey.hint2Show = YES; }
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)];
                newJersey.hint3 = temp;
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)];
                if ([temp integerValue]==0) { newJersey.hint3Show = NO; }
                if ([temp integerValue]==1) { newJersey.hint3Show = YES; }
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 15)];
                if ([temp integerValue]==0) { newJersey.solved = NO; }
                if ([temp integerValue]==1) { newJersey.solved = YES; }
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)];
                newJersey.points = [temp integerValue];
                [temp release];
                
                temp = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)];
                newJersey.currentGuess = temp;
                [temp release];
                
                //initialize the UIImage with the file location
                NSString *imageLocation = newJersey.fullName;
                imageLocation = [imageLocation stringByAppendingString:@".png"];
                newJersey.image = [UIImage imageNamed:imageLocation];
                
                //newJersey.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageLocation ofType:@"png"]];
                //NSString *fileLocation = [[NSBundle mainBundle] pathForResource:imageLocation ofType:@"png"];
                //NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
                
                //newJersey.image = [UIImage imageWithData:imageData];
                
            } else {
                NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys)); 
            }
            sqlite3_finalize(statement);
        } else {
            NSLog(@"%s SQL error '%s' (%1d)", query_stmt, sqlite3_errmsg(DB_Jerseys), sqlite3_errcode(DB_Jerseys)); 
        }
        sqlite3_close(DB_Jerseys);
    } else {
        NSLog(@"this didn't work either");
    }
    [databasePath release];
}

//UPDATES A JERSEY WITH THE FIELD NAME, STRING VALUE, AND INTEGER VALUE
- (BOOL)updateJersey:(Jersey*)jersey inField:(NSString*)field toNew:(NSString*)newValue ifInt:(int)integer
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
            querySQL = [NSString stringWithFormat: @"UPDATE jerseys SET \%@=\"%@\" WHERE fullName=\"%@\"", field, newValue, jersey.fullName];
        } else if (integer>=0) { //an int or bool value, not a string to use
            querySQL = [NSString stringWithFormat: @"UPDATE jerseys SET \%@=\"%i\" WHERE fullName=\"%@\"", field, integer, jersey.fullName];
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
}

//SHOWS HINT NUMBER ONE
- (void)showHint1
{
    if (self.hint1Show == NO) {
        self.hint1Show = YES;
        [self updateJersey:self inField:@"hint1Show" toNew:nil ifInt:1];
    }
}

//SHOWS HINT NUMBER TWO
- (void)showHint2
{
    if (self.hint2Show == NO) {
        self.hint2Show = YES;
        [self updateJersey:self inField:@"hint2Show" toNew:nil ifInt:1];
    }
}

//SHOWS HINT NUMBER THREE
- (void)showHint3
{
    if (self.hint3Show == NO) {
        self.hint3Show = YES;
        [self updateJersey:self inField:@"hint3Show" toNew:nil ifInt:1];
    }
}

//COMPARES TWO STRINGS AND DETERMINES IF THEY ARE CLOSE
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
    //if similarities are there, more than 75% of the same characters, return yes
    float f = 1.0f;
    f = f * lettersInCommon;
    f = f / [string2 length];
    
    [string1Chars release];
    [string2Chars release];
    
    if (f > 0.66) {
        return YES;
    } else {
        return NO;
    }
}

//CHECKS THE GUESS WITH A GIVEN STRING
- (NSString*)checkGuess:(NSString*)guess
{
    if (self.solved == NO) { //if the jersey has not been solved
        self.currentGuess = guess;
        
        guess = [guess lowercaseString];
        guess = [guess stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if ([guess isEqualToString:[self.printedName lowercaseString]] || [guess isEqualToString:[self.fullName lowercaseString]]) { //if the guess is correct
            self.solved = YES;
            //ADD TO PLAYER POINTS BY _points 
            //self.points = 0;
            [self updateJersey:self inField:@"solved" toNew:nil ifInt:1];
            [self updateJersey:self inField:@"currentGuess" toNew:guess ifInt:-1];
            //[self updateJersey:self inField:@"points" toNew:nil ifInt:self.points];
            return @"YES";
        } else if ([self compareStrings:guess and:[self.printedName lowercaseString]]||[self compareStrings:guess and:[self.fullName lowercaseString]]) { //IF THE GUESS IS CLOSE, OFF BY A FEW CHARACTERS
            if (self.points > 54) {
                self.points = self.points - 4;
            } else {
                self.points = 50;
            }
            [self updateJersey:self inField:@"currentGuess" toNew:guess ifInt:-1];
            [self updateJersey:self inField:@"points" toNew:nil ifInt:self.points];
            return @"CLOSE";
        } else { //if the guess is wrong
            if (self.points > 40) {
                self.points = self.points - 10;
            } else {
                self.points = 30;
            }
            [self updateJersey:self inField:@"currentGuess" toNew:guess ifInt:-1];
            [self updateJersey:self inField:@"points" toNew:nil ifInt:self.points];
            return @"NO";
        }
        
    } else { //if the jersey has already been solved
        return @"ALREADY";
    }
    
}

@end
