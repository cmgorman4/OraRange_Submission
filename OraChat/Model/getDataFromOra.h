//
//  getDataFromOra.h
//  OraChat
//
//  Created by Colin on 11/24/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getDataFromOra : NSObject
-(NSDictionary *) postToOra : (NSString *)APIExtension :(NSMutableDictionary *)jsonDictionary;
@end
