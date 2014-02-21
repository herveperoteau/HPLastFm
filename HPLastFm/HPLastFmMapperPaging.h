//
//  HPLastFmMapperPaging.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 15/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPJSONMapper.h"

@interface HPLastFmMapperPaging : HPJSONMapper

@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSInteger page;
@property (nonatomic, readonly) NSInteger perPage;
@property (nonatomic, readonly) NSInteger total;
@property (nonatomic, readonly) NSInteger totalPages;

@end
