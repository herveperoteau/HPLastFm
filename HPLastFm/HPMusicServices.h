//
//  HPServices.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 21/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ISDiskCache.h>

typedef void (^ReturnBlockWithObject)(id result);
typedef void (^ReturnBlockWithDictionary)(NSDictionary *result);
typedef void (^ReturnBlockWithError)(NSError *error);

@interface HPMusicServices : NSObject

@property (copy, nonatomic) NSString *session;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *apiKey;
@property (nonatomic) NSInteger maxConcurrentOperationCount;
@property (nonatomic) NSTimeInterval timeoutInterval;
@property (nonatomic) BOOL nextRequestIgnoresCache;
@property (nonatomic, strong) NSOperationQueue *queue;

- (NSString *)forceString:(NSString *)value;
- (NSString *)md5sumFromString:(NSString *)string;
- (NSString*)urlEscapeString:(id)unencodedString;
- (BOOL)useCache;

    
@end
