//
//  getDataFromOra.m
//  OraChat
//
//  Created by Colin on 11/24/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "getDataFromOra.h"

@interface getDataFromOra()

//@property (strong, nonatomic) NSMutableDictionary *resultsDict;
@property (strong, nonatomic) NSMutableArray *resultsArray;

@end

@implementation getDataFromOra

- (NSDictionary *) postToOra: (NSString *) APIExtension :(NSMutableDictionary *)jsonDictionary{
    //initiate mutable dictionary for results
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    //build URL based off of root url + path of API (passed in)
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://challengers.orainteractive.com%@", APIExtension]];
    //define app token
    NSString *appToken = @"d7b70a52d33796b4691da3a4e11c47cad372537f";
    //initiate URL request that will be used to contact API
    NSMutableURLRequest *request=[NSMutableURLRequest
                                  requestWithURL:url
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                  timeoutInterval:60.0];
    //add app token to json data to post
    [jsonDictionary setObject:appToken forKey:@"token"];
    NSLog(@"jsonDictionary: %@", jsonDictionary);
    NSError *error;
    //convert dictionary to json format
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    //set http method to POST to perform appropriate actions with API
    [request setHTTPMethod:@"POST"];
    //set Content-Type to application/json so the server knows what format it is recieving
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //set url request body to json data
    [request setHTTPBody:jsonData];
    NSLog(@"POSTBodyString: %@", [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding]);
    
    //define the response and error then execute the request
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    //parse the data returned
    NSError *parseError;
    id returnedObject = [NSJSONSerialization
                         JSONObjectWithData:responseData
                         options:0
                         error:&parseError];
    if (parseError) {
        NSLog(@"parseError: %@", parseError);
    }
    //check if what was returned is a dictionary
    if([returnedObject isKindOfClass:[NSDictionary class]])
    {
        //populate results from dictionary returned
        [results addEntriesFromDictionary:returnedObject];
        //check for error from post and set value to YES error if occured, NO if not
        if([[NSString stringWithFormat:@"%@", err] length]>0){
            [results setValue:@"YES" forKey:@"error"];
        } else {
            [results setValue:@"NO" forKey:@"error"];
        }
    }
    
    //using nslog to view response data
    NSLog(@"-------------RESPONSEDATASTRING-------------------");
    NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding]);
    
    return results;
}

@end
