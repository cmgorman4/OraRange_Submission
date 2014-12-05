//
//  challengeViewController.m
//  OraChat
//
//  Created by Colin on 11/24/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "challengeViewController.h"
#import "getDataFromOra.h"

@interface challengeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtChallengeWord;
@property (weak, nonatomic) IBOutlet UILabel *lblDisplayWord;
@property (strong, nonatomic) getDataFromOra *challenge;

@end

@implementation challengeViewController

- (void) viewDidLoad {
    //pull up keyboard when view loads
    [_txtChallengeWord becomeFirstResponder];
}

- (IBAction)editingChanged:(id)sender {
    //check if textbox contains any spaces, if so do not allow user to submit challenge
    NSRange whiteSpaceRange = [_txtChallengeWord.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([_txtChallengeWord.text isEqualToString:@""]){
        //if textbox is empty, clear the label text
        _lblDisplayWord.text = _txtChallengeWord.text;
    } else if (whiteSpaceRange.location != NSNotFound) {
        //check if textbox contains any spaces, if so do not allow user to submit challenge
        _lblDisplayWord.text =@"Word cannot contain spaces";
    } else if ([_txtChallengeWord.text length] < 3){
        //make sure length of word is at least 3 characters
        _lblDisplayWord.text = @"Word is too short.";
    } else if ([_txtChallengeWord.text length] >10){
        //make sure length of word is no more than 10 characters
        _lblDisplayWord.text = @"Word is too long.";
    }else if (![self isDictionaryWord: _txtChallengeWord.text]) {
        //make sure word is actually a word
        _lblDisplayWord.text = @"Not a qualifying word.";
    } else {
        //display the word and change the case to uppercase before submission
        _txtChallengeWord.text = [_txtChallengeWord.text uppercaseString];
        _lblDisplayWord.text = _txtChallengeWord.text;
    }
}

-(BOOL)isDictionaryWord:(NSString*) word {
    //check the user typed word to determine if it is properly spelled and actually a word
    UITextChecker *checker = [[UITextChecker alloc] init];
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *currentLanguage = [currentLocale objectForKey:NSLocaleLanguageCode];
    NSRange searchRange = NSMakeRange(0, [word length]);
    NSRange misspelledRange = [checker rangeOfMisspelledWordInString:[word lowercaseString] range: searchRange startingAt:0 wrap:NO language: currentLanguage ];
    return misspelledRange.location == NSNotFound;
}

- (void) submitChallenge
{
    //build post to send challenge
    NSString *messageToPost;
    messageToPost = [NSString stringWithFormat:@"!!%@", _txtChallengeWord];
    self.challenge = [[getDataFromOra alloc]init];
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:[_userDict valueForKey:@"user_token"] forKey:@"user_token"];
    [jsonDictionary setObject:_chatID forKey:@"chat_id"];
    [jsonDictionary setObject:messageToPost forKey:@"message"];
    [jsonDictionary setObject:[_userDict valueForKey:@"picture"] forKey:@"picture"];
    NSDictionary *results = [_challenge postToOra:@"/api/chats/create.json" :jsonDictionary];
    //if error while posting
    if (results && [[results valueForKey:@"error"]isEqualToString:@"YES"]) {
        //build of alert window
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"UNABLE TO SUBMIT CHALLENGE" delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        //display alert window
        [alert show];
        
    } else {
        //build alert window
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SUCCESS"
                                                        message:@"CHALLENGE SUBMITTED" delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        //display alert window
        [alert show];
        //segue to game list view
        [self performSegueWithIdentifier:@"challengeToGameList" sender:self];
    }
}

//Used to determine whether or not to close the keyboard and submit challenge
- (IBAction)keyboardHandler:(id)sender {
    //calls method in KeyboardManagerViewController (which is inherited in the header)
    if ([[_txtChallengeWord.text uppercaseString] isEqualToString:[_lblDisplayWord.text uppercaseString]]&&[_txtChallengeWord.text length]>2){
        if ([self manageKeyboard:(id) sender]){
            [self submitChallenge];
        }
    } else if ([_txtChallengeWord.text length]==0){
        _lblDisplayWord.text = @"Please enter a word.";
    }
}

@end
