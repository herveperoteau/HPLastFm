//
//  HPLastFmMapper_getInfoForAlbum.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 13/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPJSONMapper.h"

@interface HPLastFmMapper_getInfoForAlbum : HPJSONMapper

@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *year;
@property (nonatomic, readonly) NSString *urlImage;
@property (nonatomic, readonly) NSString *wiki;

@end
