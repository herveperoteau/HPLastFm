//
//  HPLastFM_Event.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 14/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapper.h"

@interface HPLastFm_Event : HPLastFmMapper

@property (nonatomic, readonly) NSString *artistHeadliner;
@property (nonatomic, readonly) NSString *descriptionEvent;
@property (nonatomic, readonly) NSString *locationName;
@property (nonatomic, readonly) CLLocationCoordinate2D gps;
@property (nonatomic, readonly) NSString *city;
@property (nonatomic, readonly) NSString *country;
@property (nonatomic, readonly) NSString *webSite;
@property (nonatomic, readonly) NSString *phoneNumber;
@property (nonatomic, readonly) NSString *urlImage;
@property (nonatomic, readonly) NSString *startDate; // "Fri, 27 Jun 2014 18:30:00";
@property (nonatomic, readonly) BOOL cancelled;

@end
