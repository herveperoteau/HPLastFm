//
//  HPLastFm.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 04/02/2014.
//  Based on https://github.com/gangverk/LastFm, but only JSON (don't use KissXML)
//
//  API http://www.lastfm.fr/api
//

#import "HPLastFm.h"
#include <CommonCrypto/CommonDigest.h>

#define API_URL @"https://ws.audioscrobbler.com/2.0/"

@interface HPLastFm ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end


@implementation HPLastFm

+ (HPLastFm *)sharedInstance {
    static dispatch_once_t pred;
    static HPLastFm *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.apiKey = @"";
        self.apiSecret = @"";
        self.queue = [[NSOperationQueue alloc] init];
        self.maxConcurrentOperationCount = 4;
        self.timeoutInterval = 10;
    }
    return self;
}

- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount {
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    self.queue.maxConcurrentOperationCount = _maxConcurrentOperationCount;
}

+ (NSDateFormatter *)dateFormatter {
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = [dictionary objectForKey:@"LFMDateFormatter"];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
        [dictionary setObject:formatter forKey:@"LFMDateFormatter"];
    }
    return formatter;
}

+ (NSDateFormatter *)alternativeDateFormatter1 {
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = [dictionary objectForKey:@"LFMDateFormatterAlt1"];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"dd MMM yyyy, HH:mm"];
        [dictionary setObject:formatter forKey:@"LFMDateFormatterAlt1"];
    }
    return formatter;
}

+ (NSDateFormatter *)alternativeDateFormatter2 {
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = [dictionary objectForKey:@"LFMDateFormatterAlt2"];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        [dictionary setObject:formatter forKey:@"LFMDateFormatterAlt2"];
    }
    return formatter;
}

+ (NSDateFormatter *)alternativeDateFormatter3 {
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = [dictionary objectForKey:@"LFMDateFormatterAlt3"];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [dictionary setObject:formatter forKey:@"LFMDateFormatterAlt3"];
    }
    return formatter;
}

+ (NSNumberFormatter *)numberFormatter {
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSNumberFormatter *formatter = [dictionary objectForKey:@"LFMNumberFormatter"];
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [dictionary setObject:formatter forKey:@"LFMNumberFormatter"];
    }
    return formatter;
}

#pragma mark - Private methods

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

- (id)transformValue:(id)value intoClass:(NSString *)targetClass {
    if ([value isKindOfClass:NSClassFromString(targetClass)]) {
        return value;
    }
    
    if ([targetClass isEqualToString:@"NSNumber"]) {
        if ([value isKindOfClass:[NSString class]] && [value length]) {
            return [[HPLastFm numberFormatter] numberFromString:value];
        }
        return @0;
    }
    
    if ([targetClass isEqualToString:@"NSURL"]) {
        if ([value isKindOfClass:[NSString class]] && [value length]) {
            return [NSURL URLWithString:value];
        }
        return nil;
    }
    
    if ([targetClass isEqualToString:@"NSDate"]) {
        NSDate *date = [[HPLastFm dateFormatter] dateFromString:value];
        if (!date) {
            date = [[HPLastFm alternativeDateFormatter1] dateFromString:value];
        }
        if (!date) {
            date = [[HPLastFm alternativeDateFormatter2] dateFromString:value];
        }
        if (!date) {
            date = [[HPLastFm alternativeDateFormatter3] dateFromString:value];
        }
        return date;
    }
    
    if ([targetClass isEqualToString:@"NSArray"]) {
        if ([value isKindOfClass:[NSString class]] && [value length]) {
            return [NSArray arrayWithObject:value];
        }
        return [NSArray array];
    }
    
    NSLog(@"Invalid targetClass (%@)", targetClass);
    return value;
}

- (NSString *)forceString:(NSString *)value {
    if (!value) return @"";
    return value;
}

- (NSString *)period:(LastFmPeriod)period {
    switch (period) {
        case kLastFmPeriodOverall:
            return @"overall";
            break;
            
        case kLastFmPeriodWeek:
            return @"7day";
            break;
            
        case kLastFmPeriodMonth:
            return @"1month";
            break;
            
        case kLastFmPeriodQuarter:
            return @"3month";
            break;
            
        case kLastFmPeriodHalfYear:
            return @"6month";
            break;
            
        case kLastFmPeriodYear:
            return @"12month";
            break;
    }
}

- (NSOperation *)performApiCallForMethod:(NSString*)method
                                  doPost:(BOOL)doPost
                                useCache:(BOOL)useCache
                              withParams:(NSDictionary *)params
                          successHandler:(LastFmReturnBlockWithObject)successHandler
                          failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
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
    [signature appendString:self.apiSecret];
    
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
                           successHandler:(LastFmReturnBlockWithObject)successHandler
                           failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
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
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
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

       // NSLog(@"%@ result JSON=%@", self.class, JSON);
        
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
                    NSError *lastfmError = [[NSError alloc] initWithDomain:LastFmServiceErrorDomain
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

#pragma mark -
#pragma mark Artist methods


//http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=Cher&api_key=2f3e308934e6170bf923bb3ec558b4e1&format=json
- (NSOperation *)getInfoForArtist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"artist.getInfo"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getEventsForArtist:(NSString *)artist
                              Limit:(NSInteger)limit
                               page:(NSInteger)page
                     successHandler:(LastFmReturnBlockWithDictionary)successHandler
                     failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"artist.getEvents"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist], @"limit": @(limit), @"page": @(page) }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTopAlbumsForArtist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"artist.getTopAlbums"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist], @"limit": @"500" }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTopTracksForArtist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"artist.getTopTracks"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist], @"limit": @"500" }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getSimilarArtistsTo:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"artist.getSimilar"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist], @"limit": @"500" }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

#pragma mark Album methods

- (NSOperation *)getInfoForAlbum:(NSString *)album artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"album.getInfo"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist], @"album": [self forceString:album], @"autocorrect": @"1" }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTracksForAlbum:(NSString *)album artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"album.getInfo"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist], @"album": [self forceString:album], @"1": @"1" }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getBuyLinksForAlbum:(NSString *)album artist:(NSString *)artist country:(NSString *)country successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"album.getBuylinks"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist], @"album": [self forceString:album], @"country": [self forceString:country] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTopTagsForAlbum:(NSString *)album artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"album.getTopTags"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"artist": [self forceString:artist], @"album": [self forceString:album] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

#pragma mark Track methods

- (NSOperation *)getInfoForTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"track.getInfo"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)loveTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"track.love"
                                  doPost:YES
                                useCache:[self useCache]
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)unloveTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"track.unlove"
                                  doPost:YES
                                useCache:[self useCache]
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)banTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"track.ban"
                                  doPost:YES
                                useCache:[self useCache]
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)unbanTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"track.unban"
                                  doPost:YES
                                useCache:[self useCache]
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getBuyLinksForTrack:(NSString *)title artist:(NSString *)artist country:(NSString *)country successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"track.getBuylinks"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist], @"country": [self forceString:country] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getSimilarTracksTo:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"track.getsimilar"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

#pragma mark User methods

// Please note: to use this method, your API key needs special permission
//- (NSOperation *)createUserWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
//    
//    NSDictionary *params = @{
//                             @"username": [self forceString:username],
//                             @"password": [self forceString:password],
//                             @"email": [self forceString:email],
//                             };
//    
//    return [self performApiCallForMethod:@"user.signUp"
//                                  doPost:NO
//                                useCache:NO
//                              withParams:params
//                          successHandler:successHandler
//                          failureHandler:failureHandler];
//}

//- (NSOperation *)getSessionForUser:(NSString *)username password:(NSString *)password successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
//    username = [self forceString:username];
//    password = [self forceString:password];
//    NSString *authToken = [self md5sumFromString:[NSString stringWithFormat:@"%@%@", [username lowercaseString], [self md5sumFromString:password]]];
//    
//    return [self performApiCallForMethod:@"auth.getMobileSession"
//                                useCache:NO
//                              withParams:@{ @"username": [username lowercaseString], @"authToken": authToken }
//                          successHandler:successHandler
//                          failureHandler:failureHandler];
//}
- (NSOperation *)getSessionForUser:(NSString *)username password:(NSString *)password successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    username = [self forceString:username];
    password = [self forceString:password];
//    NSString *authToken = [self md5sumFromString:[NSString stringWithFormat:@"%@%@", [username lowercaseString], [self md5sumFromString:password]]];

    return [self performApiCallForMethod:@"auth.getMobileSession"
                                  doPost:YES
                                useCache:NO
                              withParams:@{ @"username": [username lowercaseString], @"password": password }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getSessionInfoWithSuccessHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"auth.getSessionInfo"
                                  doPost:NO
                                useCache:NO
                              withParams:@{}
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)sendNowPlayingTrack:(NSString *)track byArtist:(NSString *)artist onAlbum:(NSString *)album successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *params = @{
                             @"track": [self forceString:track],
                             @"artist": [self forceString:artist],
                             @"album": [self forceString:album]
                             };
    
    return [self performApiCallForMethod:@"track.updateNowPlaying"
                                  doPost:YES
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)sendScrobbledTrack:(NSString *)track byArtist:(NSString *)artist onAlbum:(NSString *)album atTimestamp:(NSTimeInterval)timestamp successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *params = @{
                             @"track": [self forceString:track],
                             @"artist": [self forceString:artist],
                             @"album": [self forceString:album],
                             @"timestamp": @((int)timestamp)
                             };
    
    return [self performApiCallForMethod:@"track.scrobble"
                                  doPost:YES
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getNewReleasesForUserBasedOnRecommendations:(BOOL)basedOnRecommendations successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSDictionary *params = @{
                             @"user": [self forceString:self.username],
                             @"userec": @(basedOnRecommendations)
                             };
    
    return [self performApiCallForMethod:@"user.getNewReleases"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getRecommendedAlbumsWithLimit:(NSInteger)limit successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"user.getRecommendedAlbums"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"limit": @(limit) }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (void)logout {
    
    self.session = nil;
    self.username = nil;
}

#pragma mark General User methods

- (NSOperation *)getInfoForUserOrNil:(NSString *)username successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSDictionary *params = @{};
    if (username) {
        params = @{ @"user": [self forceString:username] };
    }
    
    return [self performApiCallForMethod:@"user.getInfo"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTopArtistsForUserOrNil:(NSString *)username period:(LastFmPeriod)period limit:(NSInteger)limit successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSDictionary *params = @{
                             @"user": username ? [self forceString:username] : [self forceString:self.username],
                             @"period": [self period:period],
                             @"limit": @(limit),
                             };
    
    return [self performApiCallForMethod:@"user.getTopArtists"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getRecentTracksForUserOrNil:(NSString *)username limit:(NSInteger)limit successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSDictionary *params = @{
                             @"user": username ? [self forceString:username] : [self forceString:self.username],
                             @"limit": @(limit),
                             };
    
    return [self performApiCallForMethod:@"user.getRecentTracks"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getLovedTracksForUserOrNil:(NSString *)username limit:(NSInteger)limit successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSDictionary *params = @{
                             @"user": username ? [self forceString:username] : [self forceString:self.username],
                             @"limit": @(limit),
                             };
    
    return [self performApiCallForMethod:@"user.getLovedTracks"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTopTracksForUserOrNil:(NSString *)username period:(LastFmPeriod)period limit:(NSInteger)limit successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSDictionary *params = @{
                             @"user": username ? [self forceString:username] : [self forceString:self.username],
                             @"period": [self period:period],
                             @"limit": @(limit),
                             };
    
    return [self performApiCallForMethod:@"user.getTopTracks"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getEventsForUserOrNil:(NSString *)username festivalsOnly:(BOOL)festivalsonly limit:(NSInteger)limit successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSDictionary *params = @{
                             @"user": username ? [self forceString:username] : [self forceString:self.username],
                             @"festivalsonly": @(festivalsonly),
                             @"limit": @(limit),
                             };
    
    return [self performApiCallForMethod:@"user.getEvents"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTopAlbumsForUserOrNil:(NSString *)username period:(LastFmPeriod)period limit:(NSInteger)limit successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSDictionary *params = @{
                             @"user": username ? [self forceString:username] : [self forceString:self.username],
                             @"period": [self period:period],
                             @"limit": @(limit),
                             };
    
    return [self performApiCallForMethod:@"user.getTopAlbums"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

#pragma mark Chart methods

- (NSOperation *)getTopTracksWithLimit:(NSInteger)limit page:(NSInteger)page successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"chart.getTopTracks"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"limit": @(limit), @"page": @(page) }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getHypedTracksWithLimit:(NSInteger)limit page:(NSInteger)page successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    return [self performApiCallForMethod:@"chart.getHypedTracks"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:@{ @"limit": @(limit), @"page": @(page) }
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

#pragma mark Geo methods

- (NSOperation *)getEventsForLongitude:(NSString *)longitude
                              Latitude:(NSString *)latitude
                                  Page:(NSInteger)page
                                 Limit:(NSInteger)limit
                                   Tag:(NSString *)tag
                        successHandler:(LastFmReturnBlockWithDictionary)successHandler
                        failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    params[@"long"] = longitude;
    params[@"lat"] = latitude;
    
    if (page!=0) params[@"page"] = @(page);
    if (limit!=0) params[@"limit"] = @(limit);
    if (tag) params[@"tag"] = tag;
    
    return [self performApiCallForMethod:@"geo.getEvents"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params

                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getEventsForLocation:(NSString *)location
                                 Page:(NSInteger)page
                                Limit:(NSInteger)limit
                                  Tag:(NSString *)tag
                       successHandler:(LastFmReturnBlockWithDictionary)successHandler
                       failureHandler:(LastFmReturnBlockWithError)failureHandler {
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    params[@"location"] = [self forceString:location];
    
    if (page!=0) params[@"page"] = @(page);
    if (limit!=0) params[@"limit"] = @(limit);
    if (tag) params[@"tag"] = tag;
    
    return [self performApiCallForMethod:@"geo.getEvents"
                                  doPost:NO
                                useCache:[self useCache]
                              withParams:params
                          successHandler:successHandler
                          failureHandler:failureHandler];
}


@end
