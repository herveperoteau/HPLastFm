//
//  HPEventFul.m
//  HPEventFul
//
//  Created by Hervé PEROTEAU on 21/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPEventFul.h"
#include <CommonCrypto/CommonDigest.h>

#define API_URL @"https://ws.audioscrobbler.com/2.0/"

@interface HPEventFul ()
@end


@implementation HPEventFul

#pragma mark - initialisation

+ (HPEventFul *)sharedInstance {
    static dispatch_once_t pred;
    static HPEventFul *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}


#pragma mark - perform request

- (NSOperation *)performApiCallForMethod:(NSString*)method
                                  doPost:(BOOL)doPost
                                useCache:(BOOL)useCache
                              withParams:(NSDictionary *)params
                          successHandler:(ReturnBlockWithObject)successHandler
                          failureHandler:(ReturnBlockWithError)failureHandler {
    
    NSMutableDictionary *newParams = [params mutableCopy];
    [newParams setObject:method forKey:@"method"];
    [newParams setObject:self.apiKey forKey:@"api_key"];
    
    if (self.session) {
        [newParams setObject:self.session forKey:@"sk"];
    }
    
    if (self.username && ![params objectForKey:@"username"]) {
        [newParams setObject:self.username forKey:@"username"];
    }
    
    // Create signature by sorting all the parameters
    NSArray *sortedParamKeys = [[newParams allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *signature = [[NSMutableString alloc] init];
    for (NSString *key in sortedParamKeys) {
        [signature appendString:[NSString stringWithFormat:@"%@%@", key, [newParams objectForKey:key]]];
    }
    
    // Check if we have the object in cache
    NSString *cacheKey = [self md5sumFromString:signature];
    
    // We need to send all the params in a sorted fashion
    NSMutableArray *sortedParamsArray = [NSMutableArray array];
    for (NSString *key in sortedParamKeys) {
        [sortedParamsArray addObject:[NSString stringWithFormat:@"%@=%@", [self urlEscapeString:key], [self urlEscapeString:[newParams objectForKey:key]]]];
    }
    
    return [self _performApiCallForMethod:method
                                   doPost:doPost
                                 useCache:useCache
                                signature:cacheKey
                    withSortedParamsArray:sortedParamsArray
                        andOriginalParams:newParams
                           successHandler:successHandler
                           failureHandler:failureHandler];
}

- (NSOperation *)_performApiCallForMethod:(NSString*)method
                                   doPost:(BOOL)doPost
                                 useCache:(BOOL)useCache
                                signature:(NSString *)signature
                    withSortedParamsArray:(NSArray *)sortedParamsArray
                        andOriginalParams:(NSDictionary *)originalParams
                           successHandler:(ReturnBlockWithObject)successHandler
                           failureHandler:(ReturnBlockWithError)failureHandler {
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    __unsafe_unretained NSBlockOperation *weakOp = op;
    
    [op addExecutionBlock:^{
        
        if ([weakOp isCancelled]) {
            return;
        }
        
        NSMutableURLRequest *request;
        if (doPost) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:API_URL]];
            request.timeoutInterval = self.timeoutInterval;
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[[NSString stringWithFormat:@"%@&api_sig=%@&format=json", [sortedParamsArray componentsJoinedByString:@"&"], signature] dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            NSString *paramsString = [NSString stringWithFormat:@"%@&api_sig=%@&format=json", [sortedParamsArray componentsJoinedByString:@"&"], signature];
            NSString *urlString = [NSString stringWithFormat:@"%@?%@", API_URL, paramsString];
            
            NSURLRequestCachePolicy policy = NSURLRequestUseProtocolCachePolicy;
            if (!useCache) {
                policy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
            }
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:policy timeoutInterval:self.timeoutInterval];
        }
        
        NSHTTPURLResponse *response;
        NSError *error;
        
        //NSLog(@"%@.sendSynchronousRequest %@ (doPost=%d)...", self.class, request.URL, doPost);
        
        NSData *data;
        
        if (useCache) {
            data = [[ISDiskCache sharedCache] objectForKey:signature];
        }
        
        if (data) {
            
            NSLog(@"%@.request %@ (sign:%@) IN CACHE", self.class, request.URL, signature);
        }
        else {
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            [[ISDiskCache sharedCache] setObject:data forKey:signature];
        }
        
        if ([weakOp isCancelled]) {
            return;
        }
        
        //        NSNumber *maxAgeNumber = [response.allHeaderFields objectForKey:@"Access-Control-Max-Age"];
        //        NSLog (@"%@.maxAgeNumber = %@", self.class, maxAgeNumber);
        
        // Check for NSURLConnection errors
        if (error) {
            if (failureHandler) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failureHandler(error);
                }];
            }
            return;
        }
        
        //        NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@ result data=%@", self.class, strData);
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&error];
        
        //NSLog(@"%@ url=%@ result JSON=%@", self.class, request.URL, JSON);
        
        // Check for JSON parsing errors
        if (error) {
            if (failureHandler) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failureHandler(error);
                }];
            }
            return;
        }
        
        // Check for Last.fm errors
        //        {
        //            "error": 10,
        //            "message": "Invalid API Key"
        //        }
        if ( [JSON objectForKey:@"error"] ) {
            if (failureHandler) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSError *lastfmError = [[NSError alloc] initWithDomain:EventFulServiceErrorDomain
                                                                      code:[[JSON objectForKey:@"error"] intValue]
                                                                  userInfo:@{NSLocalizedDescriptionKey:[JSON objectForKey:@"message"],
                                                                             @"method":method}];
                    
                    failureHandler(lastfmError);
                }];
            }
            return;
        }
        
        if (successHandler) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                successHandler(JSON);
            }];
        }
    }];
    
    [self.queue addOperation:op];
    return op;
}

- (BOOL)useCache {
    BOOL useCache = !self.nextRequestIgnoresCache;
    self.nextRequestIgnoresCache = NO;
    return useCache;
}



#pragma mark - requests

-(NSOperation *) eventsSearchWithParams:(NSDictionary *)params
                         successHandler:(ReturnBlockWithDictionary)successHandler
                         failureHandler:(ReturnBlockWithError)failureHandler {
    
    
    
    
    return nil;
}


@end
