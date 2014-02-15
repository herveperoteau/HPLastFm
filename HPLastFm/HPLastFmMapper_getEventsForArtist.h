//
//  HPLastFmMapper_getEventsForArtist.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 14/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapperPaging.h"

@interface HPLastFmMapper_getEventsForArtist : HPLastFmMapperPaging

@property (nonatomic, readonly) NSArray *events;  // Array of HPLastFm_Event

@end
