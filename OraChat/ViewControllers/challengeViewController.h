//
//  challengeViewController.h
//  OraChat
//
//  Created by Colin on 11/24/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "KeyboardManagerViewController.h"

@interface challengeViewController : KeyboardManagerViewController

@property (strong, nonatomic) NSString* userScore;
@property (strong, nonatomic) NSString* competitorScore;
@property (strong, nonatomic) NSString* round;
@property (strong, nonatomic) NSString *chatID;
@property (strong, nonatomic) NSDictionary *userDict;

@end
