//
//  LoginViewController.m
//  OraChat
//
//  Created by Colin on 11/19/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "LoginViewController.h"
#import "getDataFromOra.h"
#import "gameListViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UILabel *lblErrorMessage;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gstHideKeyboard;
@property (strong, nonatomic) getDataFromOra *oraLogin;
@property (strong, nonatomic) NSDictionary *results;
@end

@implementation LoginViewController

//Used to determine whether or not to close the keyboard as well as navigate through text fields
- (IBAction)keyboardHandler:(id)sender {
    //calls method in KeyboardManagerViewController (which is inherited in the header)
    if ([self manageKeyboard:(id) sender]){
        [self login];
    }
}

- (void) login
{
    //Check to see if user provided necessary values to attempt login
    if ([_txtEmail.text length] == 0 && [_txtPassword.text length] == 0)
    {
        _lblErrorMessage.text = @"Please enter login credentials.";
    } else if ([_txtEmail.text length] == 0)
    {
        _lblErrorMessage.text = @"Please enter your username.";
    } else if ([_txtPassword.text length] == 0)
    {
        _lblErrorMessage.text = @"Please enter your password.";
    } else {
        //build of dictionary for json submission
        NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] init];
        [jsonDictionary setObject:_txtEmail.text forKey:@"email"];
        [jsonDictionary setObject:_txtPassword.text forKey:@"password"];
        //intialize class getDataFromOra for json submission
        _oraLogin = [[getDataFromOra alloc]init];
        //call the json submission method
        _results = [_oraLogin postToOra:@"/api/users/login.json" :jsonDictionary];
        //check returned dictionary exists and there was no error during post
        if (_results && [[_results valueForKey:@"error"]isEqualToString:@"NO"]) {
            //clear out error label, store userData, perform segue to take user to list of games
            _lblErrorMessage.text = nil;
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        } else {
            //display message when error occurs on json post
            _lblErrorMessage.text = @"Unable to login.";
            /*
             *
             *
             uncomment below line to test rest of UI without being able to post to API
             *
             *
             */
            NSMutableDictionary *testResults = [[NSMutableDictionary alloc] init];
            [testResults setObject:@"1" forKey:@"id"];
            [testResults setObject:@"testToken" forKey:@"user_token"];
            [testResults setObject:@"Test Name" forKey:@"name"];
            [testResults setObject:@"iAmTesting" forKey:@"username"];
            [testResults setObject:@"testName@email.com" forKey:@"email"];
            [testResults setObject:@"0001-01-01" forKey:@"dob"];
            [testResults setObject:@"notAPicture" forKey:@"picture"];
            [testResults setObject:@"notAThumbnail" forKey:@"thumbnail"];
            _results = testResults;
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }
    }
}

- (IBAction)btnRegister:(id)sender {
    //perform segue to register page
    [self performSegueWithIdentifier:@"registerSegue" sender:sender];
    
}

- (IBAction)gstHideKeyboardAction:(id)sender {
    //calls method in KeyboardManagerViewController (which is inherited in the header)
    [self tapGestureManageKeyboard:(id)sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //check to see if segue is loginSegue
    if ([segue.identifier isEqualToString:@"loginSegue"]){
        //set userDict = to results to retain user data
        gameListViewController *controller = (gameListViewController *)segue.destinationViewController;
        controller.userDict = _results;
    }
}

@end
