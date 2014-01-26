//
//  ServerPostManger.m
//  Jarvis
//
//  Created by Joel Green on 1/25/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

//GetCards.php
// Post: user, latitude, longitude
// returns: json of each keyboard ie: {weather: {temperature:56, wind:5mph} }
//          or False for error

/*
 
{"stocks":[{"name":"Google Inc.","abbrevation":"GOOG","ask":"1130.00","bid":"0.00","price":565,"changePercent":"-3.13%"},{"name":"Facebook, Inc.","abbrevation":"FB","ask":"60.08","bid":"49.90","price":54.99,"changePercent":"-3.85%"}],"weather":{"degrees":"54","superDescriptive":"Variable winds 5 knots or less. Partly cloudy. Mixed swell... Wind waves around 1 feet."},"human":"Good afternoon. Today's weather is 54 degrees and Variable winds 5 knots or less. Partly cloudy. Mixed swell... Wind waves around 1 feet. Your stocks in Google Inc. are currently valued $565 with a net change of : -3.13%. Your stocks in Facebook, Inc. are currently valued $54.99 with a net change of : -3.85%. Have a good afternoon!"}
 
*/

#import "ServerPostManger.h"

@implementation ServerPostManger

-(NSDictionary *)incoming
{
    if (!_incoming) {
        _incoming = [[NSDictionary alloc] init];
    }
    return _incoming;
}

- (NSString *)uuid
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"uuid"]) {
        return [defaults objectForKey:@"uuid"];
    } else {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        [defaults setObject:uuidStr forKey:@"uuid"];
        [defaults synchronize];
        return uuidStr;
    }
}

- (void)requestCards:(NSDictionary *)requestDict
{
    NSMutableURLRequest *request = [self generateUrlRequest:@"http://jarvisupdate.com/GetCards.php" withDictionary:requestDict];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful in requestCards");
    }
    else {
        NSLog(@"Connection could not be made in requestCards");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    NSLog(@"data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    NSString *human = [parsedObject valueForKey:@"human"];
    
    if (human) {
        self.incoming = parsedObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Incoming Data" object:self];
    }
}

- (void)createUser:(NSDictionary *)requestDict
{
    //returns True on success and False on error
    
    NSMutableURLRequest *request = [self generateUrlRequest:@"http://jarvisupdate.com/CreateUser.php"
                                             withDictionary:requestDict];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful");
    }
    else {
        NSLog(@"Connection could not be made");
    }
}

- (void)sendStocks:(NSArray *)stocks
{
    NSDictionary *reqDict = @{@"stocks[]" : stocks, @"user" : [self uuid]};
    NSURLRequest *request = [self generateUrlRequest:@"http://jarvisupdate.com/AddStocks.php" withDictionary:reqDict];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful in sendStocks");
    }
    else {
        NSLog(@"Connection could not be made in sendStocks");
    }
}

- (void)sendRss:(NSArray *)rss
{
    NSDictionary *reqDict = @{@"rss" : [rss firstObject], @"user" : [self uuid]};
    NSURLRequest *request = [self generateUrlRequest:@"http://jarvisupdate.com/AddRss.php" withDictionary:reqDict];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful in sendStocks");
    }
    else {
        NSLog(@"Connection could not be made in sendStocks");
    }
}

- (NSMutableURLRequest *)generateUrlRequest:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *dataString = [[NSMutableString alloc] init];
    NSArray *keyArray = [dictionary allKeys];
    //makes something of form keywords[]=fuckyou&keywords[]=fuckyoumore&user=837B3070-1B7A-417E-AF8E-9AF37AD9794F
    for (NSString *key in keyArray) {
        if ([[dictionary valueForKey:key] isKindOfClass:[NSArray class]]) {
            NSArray *valueArray = [[NSArray alloc] initWithArray:[dictionary valueForKey:key]];
            for (NSString *value in valueArray){
                [dataString appendString:[NSString stringWithFormat:@"%@=%@&",key,value]];
            }
        } else {
            [dataString appendString:[NSString stringWithFormat:@"%@=%@&",key,[dictionary valueForKey:key]]];
        }
    }
    //removes trailing &
    [dataString deleteCharactersInRange:NSMakeRange([dataString length]-1,1)];
    
    NSLog(@"%@",dataString); //for debugging
    
    NSData *postData = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    return request;
}

@end
