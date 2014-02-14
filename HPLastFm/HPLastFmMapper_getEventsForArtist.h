//
//  HPLastFmMapper_getEventsForArtist.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 14/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastMapper.h"

@interface HPLastFmMapper_getEventsForArtist : HPLastMapper

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger perPage;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, strong) NSArray *events;  // Array of HPLastFm_Event

@end
