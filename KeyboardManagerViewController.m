//
//  KeyboardManagerViewController.m
//  OraChat
//
//  Created by Colin on 11/20/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "KeyboardManagerViewController.h"

@implementation KeyboardManagerViewController

- (BOOL)manageKeyboard:(id)sender {
    NSLog(@"%@", sender);
    BOOL shouldSubmit;
    //Check if UITapGestureRecognizer is sender (background of view), if so close keyboard
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]){
        //closes keyboard
        [[sender view] endEditing:YES];
    } else {
        //set incremented tag of view item to check if another text field to navigate to
        NSInteger nextTextTag = [sender tag] + 1;
        //using next incremented tag to attempt to get next text field
        UIResponder *nextResponder = [[sender superview] viewWithTag:nextTextTag];
        //check if class is UITextField and if another text field is set to switch to
        if ([sender isKindOfClass:[UITextField class]] && nextResponder){
            //switch to next textfield
            [nextResponder becomeFirstResponder];
        } else {
            //closes keyboard
            [[sender superview] endEditing:YES];
            shouldSubmit = YES;
        }
    }
    return shouldSubmit;
}

- (void)tapGestureManageKeyboard:(id)sender {
    //closes keyboards/responders
    [[sender view] endEditing:YES];
}

@end
