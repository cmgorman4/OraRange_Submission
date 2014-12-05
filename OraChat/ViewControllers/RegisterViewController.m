//
//  RegisterViewController.m
//  OraChat
//
//  Created by Colin on 11/19/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "RegisterViewController.h"
#import "getDataFromOra.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtDOB;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserPhoto;
@property (strong, nonatomic) getDataFromOra *registration;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gstHideKeyboard;
@property (weak, nonatomic) IBOutlet UILabel *lblError;

@end

@implementation RegisterViewController

- (IBAction)keyboardHandler:(id)sender {
    NSString *classType = NSStringFromClass([sender class]);
    //checks if textfield is the DOB textfield where date picker should be used
    if (([sender tag] == _txtDOB.tag || [sender tag]+1 == _txtDOB.tag) && [classType isEqualToString:@"UITextField"]){
        [self useDatePicker];
    } else {
        //calls keyboard management code to navigate/close when necessary
        [self manageKeyboard:(id)sender];
    }
}

- (void) useDatePicker{
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    //formatting date to format from API
    [self updateTxtDOB:datePicker];
    [datePicker addTarget:self action:@selector(updateTxtDOB:)
         forControlEvents:UIControlEventValueChanged];
    //sets the keyboard to date picker
    [self.txtDOB setInputView:datePicker];
    //below lines are used to set the datepicker as the first responder
    NSInteger textTag = [_txtDOB tag];
    UIResponder *dateResponder = [[_txtDOB superview] viewWithTag:textTag];
    [dateResponder becomeFirstResponder];
}

//Used to set the value for DOB from the UIDatePicker
- (void) updateTxtDOB:(UIDatePicker *)sender
{
    //dateFormatter used to set DOB text to match API format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    self.txtDOB.text = [dateFormatter stringFromDate:sender.date];
}

- (IBAction)gstHideKeyboardAction:(id)sender {
    //close keyboards
    [self tapGestureManageKeyboard:(id)sender];
}

- (IBAction)btnRegister:(id)sender {
    //register user through Ora Interactive challenge API
    //check if text fields are populated
    if ([_txtName.text length] == 0 || [_txtUsername.text length] == 0 || [_txtEmail.text length] == 0 || [_txtPassword.text length] == 0 || [_txtDOB.text length] == 0)
    {
        //if fields not fully populated, display below error, else carry on
        _lblError.text = @"Please fill out all required fields.";
    } else {
        //initiate getDataFromOra class and set dictionary to use to provide json data
        self.registration = [[getDataFromOra alloc]init];
        NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] init];
        [jsonDictionary setObject:_txtName.text forKey:@"name"];
        [jsonDictionary setObject:_txtUsername.text forKey:@"username"];
        [jsonDictionary setObject:_txtEmail.text forKey:@"email"];
        [jsonDictionary setObject:_txtPassword.text forKey:@"password"];
        [jsonDictionary setObject:_txtDOB.text forKey:@"dob"];
        //
        //
        //image test lines
        //
        //
        //returns data in PNG format for the UIImage being found by the image name and converts this to a string
        //in base64
        NSString* stringImage = [UIImagePNGRepresentation([UIImage imageNamed:@"libTech"]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [jsonDictionary setObject:stringImage forKey:@"picture"];
        //
        //
        //post to API
        NSDictionary *results = [_registration postToOra:@"/api/users/register.json" :jsonDictionary];
        if (results && [[results valueForKey:@"error"]isEqualToString:@"NO"]) {
            //clear out error label, store userData, perform segue to take user to list of games
            _lblError.text = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            //display message when error occurs on json post
            _lblError.text = @"Unable to register.";
        }
        
    }
    
}

@end
