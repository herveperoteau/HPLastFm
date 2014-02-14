//
//  HPLastFmMapper_getEventsForArtist.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 14/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapper_getEventsForArtist.h"

@implementation HPLastFmMapper_getEventsForArtist

-(NSString *) artist {
    
    if (!_artist) {
        
        NSDictionary *events = [self.datas objectForKey:@"events"];
        NSDictionary *attr = [events objectForKey:@"@attr"];
        self.artist = [attr objectForKey:@"artist"];
    }
    
    return _artist;
}





@end
