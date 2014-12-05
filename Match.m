//
//  Match.m
//  OraChat
//
//  Created by Colin on 11/21/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "Match.h"
#include <math.h>

@interface Match()

@property (strong, nonatomic) NSArray *pointAdjustArray;
@property (nonatomic)int counter;
@property (nonatomic) int origCountdownValue;
@property (strong, nonatomic) NSString *remainingTime;
@property (nonatomic) int origPointsAvailable;

@end

@implementation Match

//constant variable used to define how many points are originally available per letter
#define POINTS_PER_LETTER 20

//compare original unscrambled word to user's guess
- (BOOL) checkUserGuess: (NSString *) userGuess
{
    if ([[_stringToMatch uppercaseString] isEqualToString:[userGuess uppercaseString]])
    {
        _userCorrect = YES;
        _userScore = [NSString stringWithFormat:@"%i",[_userScore intValue] + [_pointsAvailable intValue]];
    } else {
        _userCorrect = NO;
    }
    return _userCorrect;
}

//adjust identifier of who is the current leader of the match
- (void) findCurrentLeader
{
    if ([_userScore intValue] > [_competitorScore intValue])
    {
        _currentLeader = @"◀︎";
    } else if ([_userScore intValue] < [_competitorScore intValue]){
        _currentLeader = @"▶︎";
    } else {
        _currentLeader = @"◉";
    }
}

- (void) availablePointsAdjust: (int) arrayItemToUse
{
    //#define DEFAULT_POINTS 100
    //Check if array is empty, if empty fill array with subtraction percentages for points
    //percentages are taken off of the original amount of points every 5 seconds
    if (!_pointAdjustArray){
        _pointAdjustArray = @[@"0", @".15", @".5", @".2", @".05", @".05", @".05"];
    }
    if (!_userCorrect){
        //check if passin is 0 to set the original points available for the word
        //original points calculated as length of word times POINTS_PER_LETTER (currently 20)
        if (arrayItemToUse == 0)
        {
            _pointsAvailable = [NSString stringWithFormat: @"%i", _origPointsAvailable];
        } else {
            //get appropriate value from array based on index provided from sender
            double multiplier = [[_pointAdjustArray objectAtIndex:arrayItemToUse] doubleValue];
            //calculate available point adjustment as a double so percentages from array are used
            double pointCalculation = _pointsAvailable.intValue - (_origPointsAvailable * multiplier);
            //convert the point calculation from double to integer to remove trailing zeros for label formatting
            _pointsAvailable = [NSString stringWithFormat:@"%i", (int)pointCalculation];
        }
    }
}

- (void) stringScrambler: (NSString *)wordToScramble
{
    //intiate mutable string
    if (!_scrambledWord) {
        _scrambledWord = [[NSMutableString alloc] init];
    }
    //set string to match which will be used for comparison
    _stringToMatch = wordToScramble;
    //set variable to original word
    [_scrambledWord appendString:wordToScramble];
    NSString *buffer;
    //determine original points available by multiplying points per letter by length
    _origPointsAvailable = POINTS_PER_LETTER * (int)_stringToMatch.length;
    //while loop used in case the "scrambled" word ends up being the same as the original word
    while ([_scrambledWord isEqualToString:wordToScramble])
    {
        //scramble the word by selecting random letters
        for (NSInteger i = _scrambledWord.length - 1, j; i >= 0; i--)
        {
            j = arc4random() % (i + 1);
            
            buffer = [_scrambledWord substringWithRange:NSMakeRange(i,1)];
            [_scrambledWord replaceCharactersInRange:NSMakeRange(i,1) withString:[_scrambledWord substringWithRange:NSMakeRange(j,1)]];
            [_scrambledWord replaceCharactersInRange:NSMakeRange(j, 1) withString:buffer];
        }
    }
}

//populate the scores and round of both the user and competitor
- (void) setScores{
    _userScore = @"0";
    _competitorScore = @"100";
    _round = 1;
}

@end
