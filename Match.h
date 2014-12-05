//
//  Match.h
//  OraChat
//
//  Created by Colin on 11/21/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Match : NSObject
@property (nonatomic) BOOL userCorrect;
@property (strong, nonatomic) NSString* pointsAvailable;
@property (strong, nonatomic) NSString* userScore;
@property (strong, nonatomic) NSString* competitorScore;
@property (strong, nonatomic) NSString* currentLeader;
@property (strong, nonatomic) NSMutableString* scrambledWord;
@property (nonatomic) int round;
@property (strong, nonatomic) NSString *stringToMatch;
- (BOOL) checkUserGuess: (NSString *) userGuess;
- (void) availablePointsAdjust: (int)arrayItemToUse;
- (void) stringScrambler: (NSString *)wordToScramble;
- (void) findCurrentLeader;

//TESTING
- (void) setScores;

@end
