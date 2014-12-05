//
//  MatchViewController.m
//  OraChat
//
//  Created by Colin on 11/21/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "MatchViewController.h"
#import "Match.h"
#import "challengeViewController.h"
#import "getDataFromOra.h"
#import <AudioToolbox/AudioServices.h>

@interface MatchViewController ()

@property (strong, nonatomic) Match *game;
@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblAvailablePoints;
@property (weak, nonatomic) IBOutlet UITextField *txtUserGuess;
@property (nonatomic) int counter;
@property (strong, nonatomic) getDataFromOra *oraPostGameResults;
@property (strong, nonatomic) NSMutableArray *shouldAjustPoints;
@property (weak, nonatomic) IBOutlet UILabel *lblScrambledWord;
@property (weak, nonatomic) IBOutlet UILabel *lblUserScore;
@property (weak, nonatomic) IBOutlet UILabel *lblCompetitorScore;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLeader;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentRound;

@end

@implementation MatchViewController

#define COUNTDOWN_DEFAULT 30


- (void) viewDidLoad {
    //initiate match class as game
    self.game = [[Match alloc]init];
    //calls method to get the scrambled word for the user to guess
    [self getScrambledWord];
    //first set of points available to user if guess is correct
    [_game availablePointsAdjust: 0];
    _lblAvailablePoints.text = _game.pointsAvailable;
    //sets the initial scores and round for the game
    [self setScoresAndRound];
    //gets the current round from the game for the round label
    [self getCurrentRound];
    //determine current leader of match
    [_game findCurrentLeader];
    _lblCurrentLeader.text = _game.currentLeader;
    //show scores of user and competitor
    _lblUserScore.text = _game.userScore;
    _lblCompetitorScore.text = _game.competitorScore;
    //default open of the keyboard for guessing
    [_txtUserGuess becomeFirstResponder];
    //start timer
    _lblTimer.text = [NSString stringWithFormat:@"%i",COUNTDOWN_DEFAULT];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(advanceTimer:)
                                   userInfo:nil
                                    repeats:YES];
}

//recalculates timer and determines when to adjust available points
- (void) advanceTimer:(NSTimer *)timer
{
    //recalculate timer
    _counter = _lblTimer.text.intValue - 1;
    //set variable to original timer value
    _checkAtSeconds = COUNTDOWN_DEFAULT;
    for (int i = 1; i <= 6; i++)
    {
        //loop through to determine when to adjust the points available (adjusted 6 times)
        _checkAtSeconds -= COUNTDOWN_DEFAULT/6;
        if (_counter == _checkAtSeconds){
            //calls available point adjustment
            [_game availablePointsAdjust: i];
            //sets available points on the UI
            _lblAvailablePoints.text = _game.pointsAvailable;
        }
    }
    //}
    //kill timer after it reaches 0 or when the user answers correctly
    if (_counter == 0 || _game.userCorrect){
        //kills timer
        [timer invalidate];
        _lblTimer.text = @"0";
        //vibrates phone
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        NSString* alertTitle;
        //creates title for alert window
        if (_game.userCorrect){
            alertTitle = @"Correct!";
        } else {
            alertTitle = @"Time's Up!";
        }
        //build of alert window
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:[[NSString stringWithFormat:@"Answer: %@", _game.stringToMatch] uppercaseString] delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:@"CHALLENGE", nil];
        //display alert window
        [alert show];
        [self postSeparator];
    } else {
        //adjusts value of timer displayed in UI
        [_lblTimer setText:[NSString stringWithFormat:@"%i", _counter]];
    }
}

//perform segue based on option selected from alert window
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![alertView.title isEqualToString:@"ERROR"]){
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self performSegueWithIdentifier:@"challengeSegue" sender: self];
    }
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self performSegueWithIdentifier:@"gamelistSegue" sender: self];
    }
    }
}




- (void) getScrambledWord {
    //populate array based on separaters of string
    NSArray *gameDataWord = [_gameMessageWordData componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"!!"]];
    //scramble word received from string that was populated to the array
    [_game stringScrambler:[gameDataWord objectAtIndex:2]];
    //set scrambled word label
    _lblScrambledWord.text = _game.scrambledWord;
    
}

- (void) setScoresAndRound {
    //populate array based on separaters of string
    NSArray *gameData = [_gameMessageData componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"--"]];
    //populate user score
    _game.userScore = [gameData objectAtIndex:0];
    //populate competitor score
    _game.competitorScore = [gameData objectAtIndex:2];
    //populate round
    _game.round = [[gameData objectAtIndex:4] intValue];
}

//called when user submits guess from keyboard
- (IBAction)guessSubmitted:(id)sender {
    //calls method to compare user answer to original unscrambled string
    if ([_game checkUserGuess: _txtUserGuess.text]){
        //when the user is correct the users score is updated on the UI
        _lblUserScore.text = _game.userScore;
        //when user is correct a check to determine if the current leader is performed
        //if leader has changed, arrow identifying leader is changed in UI
        [_game findCurrentLeader];
        _lblCurrentLeader.text = _game.currentLeader;
    }
}

//called during view did load to set the round label in the UI
- (void) getCurrentRound {
    _lblCurrentRound.text = [NSString stringWithFormat:@"ROUND %i", _game.round];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //check to see if segue is loginSegue
    if ([segue.identifier isEqualToString:@"challengeSegue"]){
        //pass data that should be retained for next view's post attempt
        challengeViewController *controller = (challengeViewController *)segue.destinationViewController;
        controller.userScore = _game.userScore;
        controller.competitorScore = _game.competitorScore;
        controller.round = [NSString stringWithFormat:@"%d", _game.round];
        controller.chatID = _chatID;
        controller.userDict = _userDict;
    }
}


- (void) postSeparator
{
    //initialize getDataFromOra
    _oraPostGameResults = [[getDataFromOra alloc]init];
    //create dictionary to use for post to chat messages index.
    //unable to fully determine how to get messages of only one chat
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:[NSString stringWithFormat:@"%@",[_userDict valueForKey:@"user_token"]] forKey:@"user_token"];
    [jsonDictionary setObject:_chatID forKey:@"chat_id"];
    [jsonDictionary setObject:[NSString stringWithFormat:@"%@--%@--%d", _game.userScore, _game.competitorScore, _game.round++] forKey:@"message"];
    NSDictionary *results = [_oraPostGameResults postToOra:@"/api/chats/create.json" :jsonDictionary];
    if (results && [[results valueForKey:@"error"]isEqualToString:@"YES"]) {
        //set message for game to nil and display error
        NSLog(@"%@", @"Unable to post results.");
        //build of alert window
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"UNABLE TO POST GAME RESULTS" delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        //display alert window
        [alert show];
    }
}

@end
