//
//  HPEventFul.h
//  HPEventFul
//
//  Created by Hervé PEROTEAU on 21/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPMusicServices.h"

#define EventFulServiceErrorDomain @"EventFulServiceErrorDomain"

@interface HPEventFul : HPMusicServices

@property (copy, nonatomic) NSString *session;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *apiKey;
@property (nonatomic) NSInteger maxConcurrentOperationCount; // default: 4
@property (nonatomic) NSTimeInterval timeoutInterval;        // default: 10
@property (nonatomic) BOOL nextRequestIgnoresCache;

+(HPEventFul *) sharedInstance;


// ATTENTION API PAYANTES!!!
// http://api.eventful.com/docs/events/search
-(NSOperation *) eventsSearchWithParams:(NSDictionary *)params
                         successHandler:(ReturnBlockWithDictionary)successHandler
                         failureHandler:(ReturnBlockWithError)failureHandler;



@end
