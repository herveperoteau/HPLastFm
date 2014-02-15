//
//  HPLastFmMapper_getInfoForAlbum.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 13/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapper.h"

@interface HPLastFmMapper_getInfoForAlbum : HPLastFmMapper

@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *year;
@property (nonatomic, readonly) NSString *urlImageMedium;
@property (nonatomic, readonly) NSString *urlImageLarge;
@property (nonatomic, readonly) NSString *urlImageMega;
@property (nonatomic, readonly) NSString *wiki;

@end
