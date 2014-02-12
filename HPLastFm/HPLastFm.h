//
//  HPLastFm.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 04/02/2014.
//  Based on https://github.com/gangverk/LastFm, but only JSON (don't use KissXML)
//

#import <Foundation/Foundation.h>

#define LastFmServiceErrorDomain @"LastFmServiceErrorDomain"

enum LastFmServiceErrorCodes {
	kLastFmErrorCodeInvalidService = 2,
	kLastFmErrorCodeInvalidMethod = 3,
	kLastFmErrorCodeAuthenticationFailed = 4,
	kLastFmErrorCodeInvalidFormat = 5,
	kLastFmErrorCodeInvalidParameters = 6,
	kLastFmErrorCodeInvalidResource = 7,
	kLastFmErrorCodeOperationFailed = 8,
	kLastFmErrorCodeInvalidSession = 9,
	kLastFmErrorCodeInvalidAPIKey = 10,
	kLastFmErrorCodeServiceOffline = 11,
	kLastFmErrorCodeSubscribersOnly = 12,
	kLastFmErrorCodeInvalidAPISignature = 13,
    kLastFmerrorCodeServiceError = 16
};

enum LastFmRadioErrorCodes {
	kLastFmErrorCodeTrialExpired = 18,
	kLastFmErrorCodeNotEnoughContent = 20,
	kLastFmErrorCodeNotEnoughMembers = 21,
	kLastFmErrorCodeNotEnoughFans = 22,
	kLastFmErrorCodeNotEnoughNeighbours = 23,
	kLastFmErrorCodeDeprecated = 27,
	kLastFmErrorCodeGeoRestricted = 28
};

typedef enum {
	kLastFmPeriodOverall,
    kLastFmPeriodWeek,
    kLastFmPeriodMonth,
    kLastFmPeriodQuarter,
    kLastFmPeriodHalfYear,
    kLastFmPeriodYear,
} LastFmPeriod;

typedef void (^LastFmReturnBlockWithObject)(id result);
typedef void (^LastFmReturnBlockWithDictionary)(NSDictionary *result);
//typedef void (^LastFmReturnBlockWithArray)(NSArray *result);
typedef void (^LastFmReturnBlockWithError)(NSError *error);


@interface HPLastFm : NSObject

@property (copy, nonatomic) NSString *session;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *apiKey;
@property (copy, nonatomic) NSString *apiSecret;
@property (nonatomic) NSInteger maxConcurrentOperationCount; // default: 4
@property (nonatomic) NSTimeInterval timeoutInterval;        // default: 10
@property (nonatomic) BOOL nextRequestIgnoresCache;

+ (HPLastFm *)sharedInstance;
- (NSString *)forceString:(NSString *)value;

- (NSOperation *)performApiCallForMethod:(NSString*)method
                                  doPost:(BOOL)doPost
                                useCache:(BOOL)useCache
                              withParams:(NSDictionary *)params
                          successHandler:(LastFmReturnBlockWithObject)successHandler
                          failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (id)transformValue:(id)value intoClass:(NSString *)targetClass;

///----------------------------------
/// @name Artist methods
///----------------------------------

- (NSOperation *)getInfoForArtist:(NSString *)artist
                   successHandler:(LastFmReturnBlockWithDictionary)successHandler
                   failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getEventsForArtist:(NSString *)artist
                     successHandler:(LastFmReturnBlockWithDictionary)successHandler
                     failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getTopAlbumsForArtist:(NSString *)artist
                        successHandler:(LastFmReturnBlockWithDictionary)successHandler
                        failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getTopTracksForArtist:(NSString *)artist
                        successHandler:(LastFmReturnBlockWithDictionary)successHandler
                        failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getSimilarArtistsTo:(NSString *)artist
                      successHandler:(LastFmReturnBlockWithDictionary)successHandler
                      failureHandler:(LastFmReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Album methods
///----------------------------------

- (NSOperation *)getInfoForAlbum:(NSString *)album
                          artist:(NSString *)artist
                  successHandler:(LastFmReturnBlockWithDictionary)successHandler
                  failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getTracksForAlbum:(NSString *)album
                            artist:(NSString *)artist
                    successHandler:(LastFmReturnBlockWithDictionary)successHandler
                    failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getBuyLinksForAlbum:(NSString *)album
                              artist:(NSString *)artist
                             country:(NSString *)country
                      successHandler:(LastFmReturnBlockWithDictionary)successHandler
                      failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getTopTagsForAlbum:(NSString *)album
                             artist:(NSString *)artist
                     successHandler:(LastFmReturnBlockWithDictionary)successHandler
                     failureHandler:(LastFmReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Track methods
///----------------------------------

- (NSOperation *)getInfoForTrack:(NSString *)title
                          artist:(NSString *)artist
                  successHandler:(LastFmReturnBlockWithDictionary)successHandler
                  failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)loveTrack:(NSString *)title
                    artist:(NSString *)artist
            successHandler:(LastFmReturnBlockWithDictionary)successHandler
            failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)unloveTrack:(NSString *)title
                      artist:(NSString *)artist
              successHandler:(LastFmReturnBlockWithDictionary)successHandler
              failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)banTrack:(NSString *)title
                   artist:(NSString *)artist
           successHandler:(LastFmReturnBlockWithDictionary)successHandler
           failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)unbanTrack:(NSString *)title
                     artist:(NSString *)artist
             successHandler:(LastFmReturnBlockWithDictionary)successHandler
             failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getBuyLinksForTrack:(NSString *)title
                              artist:(NSString *)artist
                             country:(NSString *)country
                      successHandler:(LastFmReturnBlockWithDictionary)successHandler
                      failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getSimilarTracksTo:(NSString *)title
                             artist:(NSString *)artist
                     successHandler:(LastFmReturnBlockWithDictionary)successHandler
                     failureHandler:(LastFmReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Authenticated User methods
///----------------------------------

//- (NSOperation *)createUserWithUsername:(NSString *)username
//                               password:(NSString *)password
//                                  email:(NSString *)email
//                         successHandler:(LastFmReturnBlockWithDictionary)successHandler
//                         failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getSessionForUser:(NSString *)username
                          password:(NSString *)password
                    successHandler:(LastFmReturnBlockWithDictionary)successHandler
                    failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getSessionInfoWithSuccessHandler:(LastFmReturnBlockWithDictionary)successHandler
                                   failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)sendNowPlayingTrack:(NSString *)track
                            byArtist:(NSString *)artist
                             onAlbum:(NSString *)album
                      successHandler:(LastFmReturnBlockWithDictionary)successHandler
                      failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)sendScrobbledTrack:(NSString *)track
                           byArtist:(NSString *)artist
                            onAlbum:(NSString *)album
                        atTimestamp:(NSTimeInterval)timestamp
                     successHandler:(LastFmReturnBlockWithDictionary)successHandler
                     failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getNewReleasesForUserBasedOnRecommendations:(BOOL)basedOnRecommendations
                                              successHandler:(LastFmReturnBlockWithDictionary)successHandler
                                              failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getRecommendedAlbumsWithLimit:(NSInteger)limit
                                successHandler:(LastFmReturnBlockWithDictionary)successHandler
                                failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (void)logout;

///----------------------------------
/// @name General User methods
///----------------------------------

- (NSOperation *)getInfoForUserOrNil:(NSString *)username
                      successHandler:(LastFmReturnBlockWithDictionary)successHandler
                      failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getTopArtistsForUserOrNil:(NSString *)username
                                    period:(LastFmPeriod)period
                                     limit:(NSInteger)limit
                            successHandler:(LastFmReturnBlockWithDictionary)successHandler
                            failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getRecentTracksForUserOrNil:(NSString *)username
                                       limit:(NSInteger)limit
                              successHandler:(LastFmReturnBlockWithDictionary)successHandler
                              failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getLovedTracksForUserOrNil:(NSString *)username
                                      limit:(NSInteger)limit
                             successHandler:(LastFmReturnBlockWithDictionary)successHandler
                             failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getTopTracksForUserOrNil:(NSString *)username
                                   period:(LastFmPeriod)period
                                    limit:(NSInteger)limit
                           successHandler:(LastFmReturnBlockWithDictionary)successHandler
                           failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getEventsForUserOrNil:(NSString *)username
                         festivalsOnly:(BOOL)festivalsonly
                                 limit:(NSInteger)limit
                        successHandler:(LastFmReturnBlockWithDictionary)successHandler
                        failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getTopAlbumsForUserOrNil:(NSString *)username
                                   period:(LastFmPeriod)period
                                    limit:(NSInteger)limit
                           successHandler:(LastFmReturnBlockWithDictionary)successHandler
                           failureHandler:(LastFmReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Chart methods
///----------------------------------

- (NSOperation *)getTopTracksWithLimit:(NSInteger)limit
                                  page:(NSInteger)page
                        successHandler:(LastFmReturnBlockWithDictionary)successHandler
                        failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getHypedTracksWithLimit:(NSInteger)limit
                                    page:(NSInteger)page
                          successHandler:(LastFmReturnBlockWithDictionary)successHandler
                          failureHandler:(LastFmReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Geo methods
///----------------------------------

- (NSOperation *)getEventsForLongitude:(NSString *)longitude
                             Latitude:(NSString *)latitude
                                  Page:(NSInteger)page
                                 Limit:(NSInteger)limit
                                 Tag:(NSString *)tag
                       successHandler:(LastFmReturnBlockWithDictionary)successHandler
                       failureHandler:(LastFmReturnBlockWithError)failureHandler;

- (NSOperation *)getEventsForLocation:(NSString *)location
                                 Page:(NSInteger)page
                                Limit:(NSInteger)limit
                                  Tag:(NSString *)tag
                        successHandler:(LastFmReturnBlockWithDictionary)successHandler
                        failureHandler:(LastFmReturnBlockWithError)failureHandler;




@end
