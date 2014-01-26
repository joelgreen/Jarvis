//
//  ServerPostManger.h
//  Jarvis
//
//  Created by Joel Green on 1/25/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerPostManger : NSObject

- (NSString *)uuid;
- (void)requestCards:(NSDictionary *)requestDict;
- (void)createUser:(NSDictionary*)requestDict;
- (void)sendStocks:(NSArray *)stocks;
- (void)sendRss:(NSArray *)rss;

@property (strong, nonatomic) NSDictionary *incoming;

@end
