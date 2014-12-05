
//
//  MatchViewController.h
//  OraChat
//
//  Created by Colin on 11/21/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchViewController : UIViewController

@property (nonatomic) int checkAtSeconds;
@property (strong, nonatomic) NSString *gameMessageData;
@property (strong, nonatomic) NSString *gameMessageWordData;
@property (strong, nonatomic) NSString *chatID;
@property (strong, nonatomic) NSDictionary *userDict;

@end
