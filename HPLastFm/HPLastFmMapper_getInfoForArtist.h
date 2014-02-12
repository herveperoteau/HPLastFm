//
//  HPLastFmMapper_getInfoForArtist.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 12/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastMapper.h"

@interface HPLastFmMapper_getInfoForArtist : HPLastMapper

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *bio;
@property (nonatomic, readonly) NSString *urlImageSmall;
@property (nonatomic, readonly) NSString *urlImageMedium;
@property (nonatomic, readonly) NSString *urlImageLarge;
@property (nonatomic, readonly) NSString *urlImageMega;
@property (nonatomic, readonly) BOOL onTour;
@property (nonatomic, readonly) NSArray *tags; // Array of NSString
@property (nonatomic, readonly) NSArray *similarArtists;  // Array of NSString

@end
