//
//  gameListViewController.h
//  OraChat
//
//  Created by Colin on 11/22/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface gameListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *userDict;

@end
