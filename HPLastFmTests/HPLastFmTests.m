//
//  HPLastFmTests.m
//  HPLastFmTests
//
//  Created by Hervé PEROTEAU on 04/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HPLastFm.h"
#import "HPLastFmMapper_getInfoForArtist.h"
#import "HPLastFmMapper_getInfoForAlbum.h"
#import "HPLastFmMapper_getEventsForArtist.h"
#import "HPLastFm_Event.h"


#define API_Key @"2f3e308934e6170bf923bb3ec558b4e1"
#define Secret  @"b53a3bb7f8a6bd6dc372bb18aef0b8ec"

#define ARTIST1 @"Rihanna"
#define ALBUM1 @"unapologetic"
#define TRACK1 @"diamonds"

#define ARTISTBAN @"Leona Lewis"
#define TRACKBAN @"Happy"

#define USERNAME_LASTFM @"herve31000"
#define PASSWORD_LASTFM @"oulmes"

#define USERNAME2_LASTFM @"xxxxxxx"
#define PASSWORD2_LASTFM @"xxxxxxx"
#define EMAIL2_LASTFM @"xxxxxxx.contact@gmail.com"

#define PARIS_LAT @"48.858859"
#define PARIS_LON @"2.34706"

#define TOULOUSE_LAT @"44.2818735"
#define TOULOUSE_LON @"1.5550732"

#define BARCELONE_LAT @"41.3934804"
#define BARCELONE_LON @"2.1646859"

@interface HPLastFmTests : XCTestCase {

    HPLastFm *lastFmManager;
    dispatch_semaphore_t semaphore;
}

@end

@implementation HPLastFmTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    semaphore = dispatch_semaphore_create(0);
    
    lastFmManager = [HPLastFm sharedInstance];
    lastFmManager.apiKey = API_Key;
    lastFmManager.apiSecret = Secret;
    
    [self login];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)login {
    
    NSDictionary *sessionJSON = [self getSessionUser];
    [lastFmManager setSession:sessionJSON[@"key"]];
    [lastFmManager setUsername:sessionJSON[@"name"]];
}

- (void)testGetInfoForArtist1
{
    NSLog(@"testGetInfoForArtist1 ... ");
    
  //  [self login];
    
    [lastFmManager getInfoForArtist:@"THE DO"
                     successHandler:^(NSDictionary *result) {
                         
                         NSLog(@"success: %@", result);
                         
                         HPLastFmMapper_getInfoForArtist *mapper = [[HPLastFmMapper_getInfoForArtist alloc] initWithDictionary:result];

                         NSLog(@"Mapper isValid=%d", mapper.isValid);
                         
                         if (mapper.isValid) {
                             
                             NSLog(@"Mapper name=%@ (onTour=%d)", mapper.name, mapper.onTour);
                             NSLog(@"Mapper bio=%@", mapper.bio);
                             NSLog(@"Mapper img=%@", mapper.urlImage);
                             NSLog(@"Mapper tags=%@", mapper.tags);
                             NSLog(@"Mapper similarArtists=%@", mapper.similarArtists);
                         }

                         dispatch_semaphore_signal(semaphore);
                     }
                     failureHandler:^(NSError *error) {
                         NSLog(@"failure: %@", error);
                         XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                         dispatch_semaphore_signal(semaphore);
                     }];

    NSLog(@"testGetInfoForArtist1 wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"testGetInfoForArtist1 Ended.");
}


-(void)testGetEventsForArtistIndochine
{
    [self getEventsForArtist1:@"indochine"];
}

-(void)testGetEventsForArtistStrokes
{
    [self getEventsForArtist1:@"strokes"];
}

-(void)testGetEventsForArtistLorde
{
    [self getEventsForArtist1:@"lorde"];
}

-(void)testGetEventsForArtistKatyPerry
{
    [self getEventsForArtist1:@"katy perry"];
}

-(void)getEventsForArtist1:(NSString *)artist {
    
    NSInteger numPage = 0;
    NSInteger maxPages = 0;
    
    do {
        numPage++;
        maxPages = [self getEventsForArtist1:artist Page:numPage];
    }
    while (numPage < maxPages);
}

- (NSInteger)getEventsForArtist1:(NSString *)artist Page:(NSInteger)page
{
    NSLog(@"testGetEventsForArtist1 ... ");
    __block NSInteger nbPages = 0;
    
    [lastFmManager getEventsForArtist:artist
                                Limit:10
                                 page:page
                           successHandler:^(NSDictionary *result) {
                               
                               //NSLog(@"success: %@", result);
                               
                               HPLastFmMapper_getEventsForArtist *mapper = [[HPLastFmMapper_getEventsForArtist alloc] initWithDictionary:result];
                               
                               NSLog(@"artist: %@", mapper.artist);
                               
                               
                               NSLog(@"page: %d / %d (Size Page=%d) (total=%d)", mapper.page, mapper.totalPages, mapper.perPage, mapper.total);
                               
                               nbPages = mapper.totalPages;
                               
                               [mapper.events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                   
                                   HPLastFm_Event *event = obj;
                                   
                                   NSLog(@"Date: %@ (cancel=%d)", event.startDate, event.cancelled);
                                   NSLog(@"artist: %@", event.artistHeadliner);
                                   NSLog(@"descriptionEvent: %@", event.descriptionEvent);
                                   NSLog(@"locationName: %@, %@(%@) GPS (%f, %f)", event.locationName, event.city, event.country,
                                         event.gps.latitude, event.gps.longitude);
                                   NSLog(@"web: %@", event.webSite);
                                   NSLog(@"tel: %@", event.phoneNumber);
                                   NSLog(@"image: %@", event.urlImage);
                                   
                                   NSLog(@"-------------------------------------------------------");
                               }];
                               
                               dispatch_semaphore_signal(semaphore);
                     }
                     failureHandler:^(NSError *error) {
                         NSLog(@"failure: %@", error);
                         XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                         dispatch_semaphore_signal(semaphore);
                     }];
    
    NSLog(@"testGetEventsForArtist1 wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"testGetEventsForArtist1 Ended.");
    
    return nbPages;
}

- (void)test_getTopAlbumsForArtist
{
//    [self getTopAlbumsForArtist:@"rihanna"];
    [self getTopAlbumsForArtist:@"the strokes"];
    [self getTopAlbumsForArtist:@"muse"];
}

- (void)getTopAlbumsForArtist:(NSString *)artist
{
    NSLog(@"test_getTopAlbumsForArtist %@ ... ", artist);
    
    [lastFmManager getTopAlbumsForArtist:artist
                          successHandler:^(NSDictionary *result) {
                              NSLog(@"success: %@", result);
                              dispatch_semaphore_signal(semaphore);
                          }
                          failureHandler:^(NSError *error) {
                              NSLog(@"failure: %@", error);
                              XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    NSLog(@"test_getTopAlbumsForArtist wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getTopAlbumsForArtist Ended.");
}



- (void)test_getTopTracksForArtist
{
    NSLog(@"test_getTopTracksForArtist ... ");
    
    [lastFmManager getTopTracksForArtist:ARTIST1
                          successHandler:^(NSDictionary *result) {
                              NSLog(@"success: %@", result);
                              dispatch_semaphore_signal(semaphore);
                          }
                          failureHandler:^(NSError *error) {
                              NSLog(@"failure: %@", error);
                              XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    NSLog(@"test_getTopTracksForArtist wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getTopTracksForArtist Ended.");
}


- (void)test_getSimilarArtistsTo
{
    NSLog(@"test_getSimilarArtistsTo ... ");
    
    [lastFmManager getSimilarArtistsTo:ARTIST1
                       successHandler:^(NSDictionary *result) {
                           NSLog(@"success: %@", result);
                           dispatch_semaphore_signal(semaphore);
                       }
                       failureHandler:^(NSError *error) {
                           NSLog(@"failure: %@", error);
                           XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                           dispatch_semaphore_signal(semaphore);
                       }];
    
    NSLog(@"test_getSimilarArtistsTo wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getSimilarArtistsTo Ended.");
}

- (void)test_getInfoForAlbum
{
    NSLog(@"test_getInfoForAlbum ... ");
    
    [lastFmManager getInfoForAlbum:@"les chansons de l'innocence retrouvée"
                            artist:@"Étienne daho"
                        successHandler:^(NSDictionary *result) {
                            
                            NSLog(@"success: %@", result);

                            HPLastFmMapper_getInfoForAlbum *mapper = [[HPLastFmMapper_getInfoForAlbum alloc] initWithDictionary:result];

                            NSLog(@"artist: %@", mapper.artist);
                            NSLog(@"title: %@", mapper.title);
                            NSLog(@"year: %@", mapper.year);
                            NSLog(@"urlImage: %@", mapper.urlImage);
                            NSLog(@"wiki: %@", mapper.wiki);
                            
                            dispatch_semaphore_signal(semaphore);
                        }
                        failureHandler:^(NSError *error) {
                            NSLog(@"failure: %@", error);
                            XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                            dispatch_semaphore_signal(semaphore);
                        }];
    
    NSLog(@"test_getInfoForAlbum wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getInfoForAlbum Ended.");
}


- (void)test_getTracksForAlbum
{
    NSLog(@"test_getTracksForAlbum ... ");
    
    [lastFmManager getTracksForAlbum:ALBUM1
                            artist:ARTIST1
                    successHandler:^(NSDictionary *result) {
                        NSLog(@"success: %@", result);
                        dispatch_semaphore_signal(semaphore);
                    }
                    failureHandler:^(NSError *error) {
                        NSLog(@"failure: %@", error);
                        XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                        dispatch_semaphore_signal(semaphore);
                    }];
    
    NSLog(@"test_getTracksForAlbum wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getTracksForAlbum Ended.");
}


- (void)test_getBuyLinksForAlbum
{
    NSLog(@"test_getBuyLinksForAlbum ... ");
    
    [lastFmManager getBuyLinksForAlbum:ALBUM1
                              artist:ARTIST1
                               country:@"fr"
                      successHandler:^(NSDictionary *result) {
                          NSLog(@"success: %@", result);
                          dispatch_semaphore_signal(semaphore);
                      }
                      failureHandler:^(NSError *error) {
                          NSLog(@"failure: %@", error);
                          XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                          dispatch_semaphore_signal(semaphore);
                      }];
    
    NSLog(@"test_getBuyLinksForAlbum wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getBuyLinksForAlbum Ended.");
}


- (void)test_getTopTagsForAlbum
{
    NSLog(@"test_getTopTagsForAlbum ... ");
 
    [lastFmManager getTopTagsForAlbum:ALBUM1
                                artist:ARTIST1
                        successHandler:^(NSDictionary *result) {
                            NSLog(@"success: %@", result);
                            dispatch_semaphore_signal(semaphore);
                        }
                        failureHandler:^(NSError *error) {
                            NSLog(@"failure: %@", error);
                            XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                            dispatch_semaphore_signal(semaphore);
                        }];
    
    NSLog(@"test_getTopTagsForAlbum wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getTopTagsForAlbum Ended.");
}


- (void)test_getInfoForTrack
{
    NSLog(@"test_getInfoForTrack ... ");
    
    [lastFmManager getInfoForTrack:TRACK1
                            artist:ARTIST1
                       successHandler:^(NSDictionary *result) {
                           NSLog(@"success: %@", result);
                           dispatch_semaphore_signal(semaphore);
                       }
                       failureHandler:^(NSError *error) {
                           NSLog(@"failure: %@", error);
                           XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                           dispatch_semaphore_signal(semaphore);
                       }];
    
    NSLog(@"test_getInfoForTrack wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getInfoForTrack Ended.");
}

- (void)test_loveTrack
{
    NSLog(@"test_loveTrack ... ");
    
    [lastFmManager loveTrack:TRACK1
                      artist:ARTIST1
                    successHandler:^(NSDictionary *result) {
                        NSLog(@"success: %@", result);
                        dispatch_semaphore_signal(semaphore);
                    }
                    failureHandler:^(NSError *error) {
                        NSLog(@"failure: %@", error);
                        XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                        dispatch_semaphore_signal(semaphore);
                    }];
    
    NSLog(@"test_loveTrack wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_loveTrack Ended.");
}

- (void)test_unloveTrack
{
    NSLog(@"test_unloveTrack ... ");
    
    [lastFmManager unloveTrack:TRACK1
                      artist:ARTIST1
              successHandler:^(NSDictionary *result) {
                  NSLog(@"success: %@", result);
                  dispatch_semaphore_signal(semaphore);
              }
              failureHandler:^(NSError *error) {
                  NSLog(@"failure: %@", error);
                  XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                  dispatch_semaphore_signal(semaphore);
              }];
    
    NSLog(@"test_unloveTrack wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_unloveTrack Ended.");
}

- (void)test_banTrack
{
    NSLog(@"test_banTrack ... ");
    
    [lastFmManager banTrack:TRACKBAN
                     artist:ARTISTBAN
                successHandler:^(NSDictionary *result) {
                    NSLog(@"success: %@", result);
                    dispatch_semaphore_signal(semaphore);
                }
                failureHandler:^(NSError *error) {
                    NSLog(@"failure: %@", error);
                    dispatch_semaphore_signal(semaphore);
                    XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                }];
    
    NSLog(@"test_banTrack wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_banTrack Ended.");
}

- (void)test_unbanTrack
{
    NSLog(@"test_unbanTrack ... ");
    
    [lastFmManager unbanTrack:TRACKBAN
                     artist:ARTISTBAN
             successHandler:^(NSDictionary *result) {
                 NSLog(@"success: %@", result);
                 dispatch_semaphore_signal(semaphore);
             }
             failureHandler:^(NSError *error) {
                 NSLog(@"failure: %@", error);
                 XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                 dispatch_semaphore_signal(semaphore);
             }];
    
    NSLog(@"test_unbanTrack wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_unbanTrack Ended.");
}


- (void)test_getBuyLinksForTrack
{
    NSLog(@"test_getBuyLinksForTrack ... ");
    
    [lastFmManager getBuyLinksForTrack:TRACK1
                                artist:ARTIST1
                               country:@"fr"
               successHandler:^(NSDictionary *result) {
                   NSLog(@"success: %@", result);
                   dispatch_semaphore_signal(semaphore);
               }
               failureHandler:^(NSError *error) {
                   NSLog(@"failure: %@", error);
                   XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                   dispatch_semaphore_signal(semaphore);
               }];
    
    NSLog(@"test_getBuyLinksForTrack wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getBuyLinksForTrack Ended.");
}

//-(void) test_createUserWithUsername
//{
//    NSLog(@"test_createUserWithUsername ... ");
//    
//    [lastFmManager createUserWithUsername:USERNAME2_LASTFM
//                                 password:PASSWORD2_LASTFM
//                                    email:EMAIL2_LASTFM
//     
//                      successHandler:^(NSDictionary *result) {
//                          
//                          NSLog(@"success: %@", result);
//                          dispatch_semaphore_signal(semaphore);
//                      }
//                      failureHandler:^(NSError *error) {
//                          NSLog(@"failure: %@", error);
//                          XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
//                          dispatch_semaphore_signal(semaphore);
//                      }];
//    
//    NSLog(@"test_createUserWithUsername wait ... ");
//    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
//    NSLog(@"test_createUserWithUsername Ended.");
//}


- (void)test_getSessionForUser
{
    NSLog(@"test_getSessionForUser ... ");
    
    [lastFmManager getSessionForUser:USERNAME_LASTFM
                                password:PASSWORD_LASTFM
                        successHandler:^(NSDictionary *result) {
                         
                            NSLog(@"success: %@", result);
                            NSDictionary *session = result[@"session"];
                            NSLog(@"key=%@", session[@"key"]);
                            
                            dispatch_semaphore_signal(semaphore);
                        }
                        failureHandler:^(NSError *error) {
                            NSLog(@"failure: %@", error);
                            XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                            dispatch_semaphore_signal(semaphore);
                        }];
    
    NSLog(@"test_getSessionForUser wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getSessionForUser Ended.");
}


- (void)test_sendNowPlayingTrack
{
    NSLog(@"test_sendNowPlayingTrack ... ");
    
    [lastFmManager sendNowPlayingTrack:TRACK1
                              byArtist:ARTIST1
                               onAlbum:ALBUM1
     
                      successHandler:^(NSDictionary *result) {
                          
                          NSLog(@"success: %@", result);
                          dispatch_semaphore_signal(semaphore);
                      }
                      failureHandler:^(NSError *error) {
                          NSLog(@"failure: %@", error);
                          XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                          dispatch_semaphore_signal(semaphore);
                      }];
    
    NSLog(@"test_sendNowPlayingTrack wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_sendNowPlayingTrack Ended.");
}


- (void)test_sendScrobbledTrack
{
    NSLog(@"test_sendScrobbledTrack ... ");
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    
    [lastFmManager sendScrobbledTrack:TRACK1
                              byArtist:ARTIST1
                               onAlbum:ALBUM1
                             atTimestamp:timestamp

                        successHandler:^(NSDictionary *result) {
                            
                            NSLog(@"success: %@", result);
                            dispatch_semaphore_signal(semaphore);
                        }
                        failureHandler:^(NSError *error) {
                            NSLog(@"failure: %@", error);
                            XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                            dispatch_semaphore_signal(semaphore);
                        }];
    
    NSLog(@"test_sendScrobbledTrack wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_sendScrobbledTrack Ended.");
}

- (void)test_getNewReleasesForUserBasedOnRecommendations
{
    NSLog(@"test_getNewReleasesForUserBasedOnRecommendations ... ");
    
    [lastFmManager getNewReleasesForUserBasedOnRecommendations:YES
     
                       successHandler:^(NSDictionary *result) {
                           
                           NSLog(@"success: %@", result);
                           dispatch_semaphore_signal(semaphore);
                       }
                       failureHandler:^(NSError *error) {
                           NSLog(@"failure: %@", error);
                           XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                           dispatch_semaphore_signal(semaphore);
                       }];
    
    NSLog(@"test_getNewReleasesForUserBasedOnRecommendations wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getNewReleasesForUserBasedOnRecommendations Ended.");
}

- (void)test_getRecommendedAlbumsWithLimit
{
    NSLog(@"test_getRecommendedAlbumsWithLimit ... ");
    
    [lastFmManager getRecommendedAlbumsWithLimit:10
                                                successHandler:^(NSDictionary *result) {
                                                    
                                                    NSLog(@"success: %@", result);
                                                    dispatch_semaphore_signal(semaphore);
                                                }
                                                failureHandler:^(NSError *error) {
                                                    NSLog(@"failure: %@", error);
                                                    XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                                                    dispatch_semaphore_signal(semaphore);
                                                }];
    
    NSLog(@"test_getRecommendedAlbumsWithLimit wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getRecommendedAlbumsWithLimit Ended.");
}


- (void)test_logout
{
    NSLog(@"test_logout ... ");
    [lastFmManager logout];
    NSLog(@"test_logout Ended.");
}


- (void)test_getEventsForLocationGpsToulouse
{
    NSLog(@"test_getEventsForLocationGpsToulouse ... ");
    
    [lastFmManager getEventsForLongitude:TOULOUSE_LON
                                Latitude:TOULOUSE_LAT
                                    Page:1
                                   Limit:50
                                     Tag:nil
     
                                  successHandler:^(NSDictionary *result) {
                                      
                                      NSLog(@"success: %@", result);
                                      dispatch_semaphore_signal(semaphore);
                                  }
                                  failureHandler:^(NSError *error) {
                                      NSLog(@"failure: %@", error);
                                      XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                                      dispatch_semaphore_signal(semaphore);
                                  }];
    
    NSLog(@"test_getEventsForLocationGpsToulouse wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getEventsForLocationGpsToulouse Ended.");
}


- (void)test_getEventsForLocationGpsParis
{
    NSLog(@"test_getEventsForLocationGpsParis ... ");
    
    [lastFmManager getEventsForLongitude:PARIS_LON
                                Latitude:PARIS_LAT
                                    Page:0
                                   Limit:0
                                     Tag:nil
     
                          successHandler:^(NSDictionary *result) {
                              
                              NSLog(@"success: %@", result);
                              dispatch_semaphore_signal(semaphore);
                          }
                          failureHandler:^(NSError *error) {
                              NSLog(@"failure: %@", error);
                              XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    NSLog(@"test_getEventsForLocationGpsParis wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getEventsForLocationGpsParis Ended.");
}


- (void)test_getEventsForLocationGpsBarcelone
{
    NSLog(@"test_getEventsForLocationGpsBarcelone ... ");
    
    [lastFmManager getEventsForLongitude:BARCELONE_LON
                                Latitude:BARCELONE_LAT
                                    Page:0
                                   Limit:0
                                     Tag:nil
     
                          successHandler:^(NSDictionary *result) {
                              
                              NSLog(@"success: %@", result);
                              dispatch_semaphore_signal(semaphore);
                          }
                          failureHandler:^(NSError *error) {
                              NSLog(@"failure: %@", error);
                              XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    NSLog(@"test_getEventsForLocationGpsBarcelone wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getEventsForLocationGpsBarcelone Ended.");
}

- (void)test_getEventsForLocationToulouse
{
    NSLog(@"test_getEventsForLocationToulouse ... ");
    
    [lastFmManager getEventsForLocation:@"toulouse"
                                   Page:0
                                  Limit:0
                                    Tag:@"rock"
     
                          successHandler:^(NSDictionary *result) {
                              
                              NSLog(@"success: %@", result);
                              dispatch_semaphore_signal(semaphore);
                          }
                          failureHandler:^(NSError *error) {
                              NSLog(@"failure: %@", error);
                              XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    NSLog(@"test_getEventsForLocationToulouse wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_getEventsForLocationToulouse Ended.");
}

-(void) testRegexp {
    
    [self.class cleanPrefixAlbumTitle:@"1- Blabla   "];
    [self.class cleanPrefixAlbumTitle:@"01- Blabla   "];
    [self.class cleanPrefixAlbumTitle:@"01, Blabla   "];
    [self.class cleanPrefixAlbumTitle:@"01* Blabla   "];
    [self.class cleanPrefixAlbumTitle:@"01: Blabla   "];
    [self.class cleanPrefixAlbumTitle:@"01 Blabla   "];
    [self.class cleanPrefixAlbumTitle:@"1964"];
    [self.class cleanPrefixAlbumTitle:@"blabla dsf dsfsd fds 01, dsfds"];
}

-(void) testCleanAccent  {

    NSLog(@"%@", [self.class cleanAccents:@"étienne"]);
    NSLog(@"%@", [self.class cleanAccents:@"éàèùç"]);
    NSLog(@"%@", [self.class cleanAccents:@"ÀÉÈÙ"]);
}

#pragma mark - Private

+(NSString *) cleanAccents:(NSString *) item {
    
    NSMutableString *string = [item mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(string), NULL, kCFStringTransformStripCombiningMarks, NO);
    return [NSString stringWithString:string];
    //return [item stringByFoldingWithOptions: NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
}

+(NSString *) cleanPrefixAlbumTitle:(NSString *) title {
    
    NSString *result = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //01, title
    
    NSRange rangePrefixNumber = [result rangeOfString:@"^\\d{1,2}[ *,:-]" options:NSRegularExpressionSearch];
    
    NSLog(@"rangePrefixNumber.location=%d lenght=%d", rangePrefixNumber.location, rangePrefixNumber.length);

    if (rangePrefixNumber.location != NSNotFound) {
        
        result = [result substringFromIndex:rangePrefixNumber.location+rangePrefixNumber.length];
        result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    NSLog(@"cleanPrefixAlbumTitle(%@)=(%@)", title, result);

    return result;
}

-(NSDictionary *) getSessionUser {

    __block NSDictionary *sessionJSON = nil;
    
    dispatch_semaphore_t synchro = dispatch_semaphore_create(0);

    [lastFmManager getSessionForUser:USERNAME_LASTFM
                            password:PASSWORD_LASTFM
                      successHandler:^(NSDictionary *result) {
                          
                          NSLog(@"success: %@", result);
                          sessionJSON = [NSDictionary dictionaryWithDictionary:result[@"session"]];
                          dispatch_semaphore_signal(synchro);
                      }
                      failureHandler:^(NSError *error) {
                          
                          NSLog(@"failure: %@", error);
                          dispatch_semaphore_signal(synchro);
                      }];
    
    NSLog(@"wait ...");
    
    while (dispatch_semaphore_wait(synchro, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    NSLog(@"OK sessionJSON = %@", sessionJSON);
    
    return sessionJSON;
}

@end
