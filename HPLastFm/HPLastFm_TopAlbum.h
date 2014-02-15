//
//  HPLastFm_Album.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 15/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapper.h"

@interface HPLastFm_TopAlbum : HPLastFmMapper

@property (nonatomic, readonly) NSInteger rank;
@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *urlImage;

@end
