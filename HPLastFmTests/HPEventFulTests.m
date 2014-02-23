//
//  HPEventFulTests.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 21/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HPEventFul.h"

#define APIKey_EventFul @"vZqzrNV8Shxp3cM8"

@interface HPEventFulTests : XCTestCase {

    HPEventFul *manager;
    dispatch_semaphore_t semaphore;
}

@end

@implementation HPEventFulTests

- (void)setUp
{
    [super setUp];

    semaphore = dispatch_semaphore_create(0);
    
    manager = [HPEventFul sharedInstance];
    manager.apiKey = APIKey_EventFul;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)_EventsSearchWithParams
{
    NSLog(@"test_EventsSearchWithParams ... ");
    
    NSDictionary *params = @{@"keywords":@"indochine", @"sort_order":@"date", @"page_number":@"1", @"page_size" : @"100", @"image_sizes":@"block100,large,blackborder500"};
    
    [manager  eventsSearchWithParams:params
                      successHandler:^(NSDictionary *result) {
                      
                          NSLog(@"success: %@", result);
                          dispatch_semaphore_signal(semaphore);
                      }
                      failureHandler:^(NSError *error) {
         
                          NSLog(@"failure: %@", error);
                          XCTAssertTrue(NO, @"error: %@", [error localizedDescription]);
                          dispatch_semaphore_signal(semaphore);

                      } ];
    
    NSLog(@"test_EventsSearchWithParams wait ... ");
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    NSLog(@"test_EventsSearchWithParams Ended.");
}

@end
