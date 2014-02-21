//
//  HPLastFm_Album.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 15/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPJSONMapper.h"

@interface HPLastFm_TopAlbum : HPJSONMapper

@property (nonatomic, readonly) NSInteger rank;
@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *urlImage;

@end
