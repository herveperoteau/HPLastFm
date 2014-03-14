//
//  HPLastFM_Event.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 14/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "HPJSONMapper.h"

@interface HPLastFm_Event : HPJSONMapper

@property (nonatomic, readonly) NSString *idEvent;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *artistHeadliner;
@property (nonatomic, readonly) NSArray *artists;
@property (nonatomic, readonly) NSString *descriptionEvent;
@property (nonatomic, readonly) NSString *locationName;
@property (nonatomic, readonly) CLLocationCoordinate2D gps;
@property (nonatomic, readonly) NSString *city;
@property (nonatomic, readonly) NSString *country;
@property (nonatomic, readonly) NSString *webSite;
@property (nonatomic, readonly) NSString *phoneNumber;
@property (nonatomic, readonly) NSString *urlImageEvent;
@property (nonatomic, readonly) NSString *urlImageVenue;
@property (nonatomic, readonly) NSString *startDateString; // "Fri, 27 Jun 2014 18:30:00";
@property (nonatomic, readonly) NSString *endDateString;   // "Sun, 20 Jul 2014 16:05:01";
@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;
@property (nonatomic, readonly) BOOL cancelled;
@property (nonatomic, readonly) NSArray *tags;

@end
