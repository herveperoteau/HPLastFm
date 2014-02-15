//
//  HPLastFmMapper_getInfoForArtist.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 12/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapper.h"

#define kSimilarArtistName @"NAME"
#define kSimilarArtistImage @"IMAGE"

@interface HPLastFmMapper_getInfoForArtist : HPLastFmMapper

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *bio;
@property (nonatomic, readonly) NSString *urlImage;
@property (nonatomic, readonly) BOOL onTour;
@property (nonatomic, readonly) NSArray *tags; // Array of NSString
@property (nonatomic, readonly) NSArray *similarArtists;  // Array of NSDictionnary keys:kSimilarXXX 

@end
