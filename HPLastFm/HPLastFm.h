//
//  HPLastFm.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 04/02/2014.
//  Based on https://github.com/gangverk/LastFm, but only JSON (don't use KissXML)
//

#import <Foundation/Foundation.h>

#import "HPMusicServices.h"

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

@interface HPLastFm : HPMusicServices

@property (copy, nonatomic) NSString *apiSecret;

+ (HPLastFm *)sharedInstance;

- (NSOperation *)performApiCallForMethod:(NSString*)method
                                  doPost:(BOOL)doPost
                                useCache:(BOOL)useCache
                              withParams:(NSDictionary *)params
                          successHandler:(ReturnBlockWithObject)successHandler
                          failureHandler:(ReturnBlockWithError)failureHandler;

- (id)transformValue:(id)value intoClass:(NSString *)targetClass;

///----------------------------------
/// @name Artist methods
///----------------------------------

//- (NSOperation *)getInfoForArtist:(NSString *)artist
//                       Background:(BOOL)flagBackgroundQueue
//                   successHandler:(ReturnBlockWithDictionary)successHandler
//                   failureHandler:(ReturnBlockWithError)failureHandler;

- (NSURLSessionDataTask *) createTaskGetInfoForArtist:(NSString *)artist
                                       successHandler:(ReturnBlockWithDictionary)successHandler
                                       failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getEventsForArtist:(NSString *)artist
                              Limit:(NSInteger)limit
                               page:(NSInteger)page
                     successHandler:(ReturnBlockWithDictionary)successHandler
                     failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getTopAlbumsForArtist:(NSString *)artist
                        successHandler:(ReturnBlockWithDictionary)successHandler
                        failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getTopTracksForArtist:(NSString *)artist
                        successHandler:(ReturnBlockWithDictionary)successHandler
                        failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getSimilarArtistsTo:(NSString *)artist
                      successHandler:(ReturnBlockWithDictionary)successHandler
                      failureHandler:(ReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Album methods
///----------------------------------

//- (NSOperation *)getInfoForAlbum:(NSString *)album
//                          artist:(NSString *)artist
//                      Background:(BOOL)flagBackgroundQueue
//                  successHandler:(ReturnBlockWithDictionary)successHandler
//                  failureHandler:(ReturnBlockWithError)failureHandler;

- (NSURLSessionDataTask *) createTaskGetInfoForAlbum:(NSString *)album
                                              artist:(NSString *)artist
                                      successHandler:(ReturnBlockWithDictionary)successHandler
                                      failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getTracksForAlbum:(NSString *)album
                            artist:(NSString *)artist
                    successHandler:(ReturnBlockWithDictionary)successHandler
                    failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getBuyLinksForAlbum:(NSString *)album
                              artist:(NSString *)artist
                             country:(NSString *)country
                      successHandler:(ReturnBlockWithDictionary)successHandler
                      failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getTopTagsForAlbum:(NSString *)album
                             artist:(NSString *)artist
                     successHandler:(ReturnBlockWithDictionary)successHandler
                     failureHandler:(ReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Track methods
///----------------------------------

- (NSOperation *)getInfoForTrack:(NSString *)title
                          artist:(NSString *)artist
                  successHandler:(ReturnBlockWithDictionary)successHandler
                  failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)loveTrack:(NSString *)title
                    artist:(NSString *)artist
            successHandler:(ReturnBlockWithDictionary)successHandler
            failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)unloveTrack:(NSString *)title
                      artist:(NSString *)artist
              successHandler:(ReturnBlockWithDictionary)successHandler
              failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)banTrack:(NSString *)title
                   artist:(NSString *)artist
           successHandler:(ReturnBlockWithDictionary)successHandler
           failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)unbanTrack:(NSString *)title
                     artist:(NSString *)artist
             successHandler:(ReturnBlockWithDictionary)successHandler
             failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getBuyLinksForTrack:(NSString *)title
                              artist:(NSString *)artist
                             country:(NSString *)country
                      successHandler:(ReturnBlockWithDictionary)successHandler
                      failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getSimilarTracksTo:(NSString *)title
                             artist:(NSString *)artist
                     successHandler:(ReturnBlockWithDictionary)successHandler
                     failureHandler:(ReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Authenticated User methods
///----------------------------------

//- (NSOperation *)createUserWithUsername:(NSString *)username
//                               password:(NSString *)password
//                                  email:(NSString *)email
//                         successHandler:(ReturnBlockWithDictionary)successHandler
//                         failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getSessionForUser:(NSString *)username
                          password:(NSString *)password
                    successHandler:(ReturnBlockWithDictionary)successHandler
                    failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getSessionInfoWithSuccessHandler:(ReturnBlockWithDictionary)successHandler
                                   failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)sendNowPlayingTrack:(NSString *)track
                            byArtist:(NSString *)artist
                             onAlbum:(NSString *)album
                      successHandler:(ReturnBlockWithDictionary)successHandler
                      failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)sendScrobbledTrack:(NSString *)track
                           byArtist:(NSString *)artist
                            onAlbum:(NSString *)album
                        atTimestamp:(NSTimeInterval)timestamp
                     successHandler:(ReturnBlockWithDictionary)successHandler
                     failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getNewReleasesForUserBasedOnRecommendations:(BOOL)basedOnRecommendations
                                              successHandler:(ReturnBlockWithDictionary)successHandler
                                              failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getRecommendedAlbumsWithLimit:(NSInteger)limit
                                successHandler:(ReturnBlockWithDictionary)successHandler
                                failureHandler:(ReturnBlockWithError)failureHandler;

- (void)logout;

///----------------------------------
/// @name General User methods
///----------------------------------

- (NSOperation *)getInfoForUserOrNil:(NSString *)username
                      successHandler:(ReturnBlockWithDictionary)successHandler
                      failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getTopArtistsForUserOrNil:(NSString *)username
                                    period:(LastFmPeriod)period
                                     limit:(NSInteger)limit
                            successHandler:(ReturnBlockWithDictionary)successHandler
                            failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getRecentTracksForUserOrNil:(NSString *)username
                                       limit:(NSInteger)limit
                              successHandler:(ReturnBlockWithDictionary)successHandler
                              failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getLovedTracksForUserOrNil:(NSString *)username
                                      limit:(NSInteger)limit
                             successHandler:(ReturnBlockWithDictionary)successHandler
                             failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getTopTracksForUserOrNil:(NSString *)username
                                   period:(LastFmPeriod)period
                                    limit:(NSInteger)limit
                           successHandler:(ReturnBlockWithDictionary)successHandler
                           failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getEventsForUserOrNil:(NSString *)username
                         festivalsOnly:(BOOL)festivalsonly
                                 limit:(NSInteger)limit
                        successHandler:(ReturnBlockWithDictionary)successHandler
                        failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getTopAlbumsForUserOrNil:(NSString *)username
                                   period:(LastFmPeriod)period
                                    limit:(NSInteger)limit
                           successHandler:(ReturnBlockWithDictionary)successHandler
                           failureHandler:(ReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Chart methods
///----------------------------------

- (NSOperation *)getTopTracksWithLimit:(NSInteger)limit
                                  page:(NSInteger)page
                        successHandler:(ReturnBlockWithDictionary)successHandler
                        failureHandler:(ReturnBlockWithError)failureHandler;

- (NSOperation *)getHypedTracksWithLimit:(NSInteger)limit
                                    page:(NSInteger)page
                          successHandler:(ReturnBlockWithDictionary)successHandler
                          failureHandler:(ReturnBlockWithError)failureHandler;

///----------------------------------
/// @name Geo methods
///----------------------------------

-(NSOperation *) getEventsForLongitude:(NSString *)longitude
                               Latitude:(NSString *)latitude
                               Distance:(NSString *)distance
                                   Page:(NSInteger)page
                                  Limit:(NSInteger)limit
                                    Tag:(NSString *)tag
                         successHandler:(ReturnBlockWithDictionary)successHandler
                         failureHandler:(ReturnBlockWithError)failureHandler;

-(NSOperation *) getEventsForLocation:(NSString *)location
                                  Page:(NSInteger)page
                                 Limit:(NSInteger)limit
                                   Tag:(NSString *)tag
                            successHandler:(ReturnBlockWithDictionary)successHandler
                            failureHandler:(ReturnBlockWithError)failureHandler;


@end
