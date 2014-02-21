//
//  HPServices.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 21/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPMusicServices.h"
#include <CommonCrypto/CommonDigest.h>
#import <ISDiskCache/ISDiskCache.h>

@implementation HPMusicServices

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.apiKey = @"";
        self.queue = [[NSOperationQueue alloc] init];
        self.maxConcurrentOperationCount = 4;
        self.timeoutInterval = 10;
        
        [[ISDiskCache sharedCache] setLimitOfSize:100 * 1024 * 1024]; // 100MB
        
        NSDate *datePurgeCache = [NSDate dateWithTimeIntervalSinceNow:-86400*7];
        [[ISDiskCache sharedCache] removeObjectsByAccessedDate:datePurgeCache];
    }
    
    return self;
}

- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount {
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    self.queue.maxConcurrentOperationCount = _maxConcurrentOperationCount;
}

- (BOOL)useCache {
    BOOL useCache = !self.nextRequestIgnoresCache;
    self.nextRequestIgnoresCache = NO;
    return useCache;
}

- (NSString *)forceString:(NSString *)value {
    if (!value) return @"";
    return value;
}


- (NSString *)md5sumFromString:(NSString *)string {
	unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
	CC_MD5([string UTF8String], [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
	NSMutableString *ms = [NSMutableString string];
	for (i=0;i<CC_MD5_DIGEST_LENGTH;i++) {
		[ms appendFormat: @"%02x", (int)(digest[i])];
	}
	return [ms copy];
}

- (NSString*)urlEscapeString:(id)unencodedString {
    if ([unencodedString isKindOfClass:[NSString class]]) {
        NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                            NULL,
                                                                                            (__bridge CFStringRef)unencodedString,
                                                                                            NULL,
                                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8
                                                                                            );
        return s;
    }
    return unencodedString;
}

@end
