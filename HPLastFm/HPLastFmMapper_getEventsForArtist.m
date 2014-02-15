//
//  HPLastFmMapper_getEventsForArtist.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 14/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapper_getEventsForArtist.h"
#import "HPLastFm_Event.h"

@interface HPLastFmMapper_getEventsForArtist ()

@property (nonatomic, strong) NSArray *events;  // Array of HPLastFm_Event

@end

@implementation HPLastFmMapper_getEventsForArtist

-(NSArray *) events {
    
    if (!_events) {
        
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        
        id eventJSON = [self.datas valueForKeyPath:@"events.event"];
        
        if ( [eventJSON isKindOfClass:[NSArray class]] ) {
        
            NSArray *eventArrayJSON = eventJSON;
            
            [eventArrayJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *eventJSON = obj;
                HPLastFm_Event *event = [[HPLastFm_Event alloc] initWithDictionary:eventJSON];
                [tmpArray addObject:event];
            }];
        }
        else if ( [eventJSON isKindOfClass:[NSDictionary class]] ) {
        
            // Only one item
            HPLastFm_Event *event = [[HPLastFm_Event alloc] initWithDictionary:eventJSON];
            [tmpArray addObject:event];
        }
        
        self.events = [NSArray arrayWithArray:tmpArray];
    }
    
    return _events;
}


@end
