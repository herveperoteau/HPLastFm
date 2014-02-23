//
//  HPLastFm_Event
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 14/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFm.h"
#import "HPLastFm_Event.h"
#import <NSString+HTML.h>

@interface HPLastFm_Event ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artistHeadliner;
@property (nonatomic, strong) NSArray *artists;
@property (nonatomic, strong) NSString *descriptionEvent;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSString *latGps;
@property (nonatomic, strong) NSString *lonGps;
@property (nonatomic, assign) CLLocationCoordinate2D coordGPS;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *webSite;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *urlImage;
@property (nonatomic, strong) NSString *startDateString;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSString *endDateString;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) NSNumber *cancelledNumber;

@end

@implementation HPLastFm_Event

-(NSString *) title {
    
    if (!_title) {
        
        self.title = [self.datas valueForKeyPath:@"title"];
    }
    
    return _title;
}


-(NSString *) artistHeadliner {
    
    if (!_artistHeadliner) {
        
        self.artistHeadliner = [self.datas valueForKeyPath:@"artists.headliner"];
    }
    
    return _artistHeadliner;
}

//artists =                 {
//    artist =                     (
//                                  MGMT,
//                                  Phoenix,
//                                  Blondie,
//                                  UB40,
//                                  Indochine,
//                                  "Shaka Ponk",
//                                  "-M-",
//                                  "Ga\U00ebtan Roussel",
//                                  FAUVE,
//                                  "F.F.F."
//                                  );
//    headliner = MGMT;
//};

-(NSArray *) artists {
    
    if (!_artists) {
        
        id artistsJSON = [self.datas valueForKeyPath:@"artists.artist"];
        
        if ([artistsJSON isKindOfClass:NSArray.class]) {
            
            self.artists = [NSArray arrayWithArray:artistsJSON];
        }
        else {
            
            self.artists = [NSArray arrayWithObject:artistsJSON];
        }
    }
    
    return _artists;
}

-(NSString *) descriptionEvent {
    
    if (!_descriptionEvent) {
        
        NSString *tmp = [self.datas valueForKeyPath:@"description"];
        self.descriptionEvent = [tmp stringByConvertingHTMLToPlainText];

    }
    
    return _descriptionEvent;
}

-(NSString *) locationName {
    
    if (!_locationName) {
        
        self.locationName = [self.datas valueForKeyPath:@"venue.name"];
    }
    
    return _locationName;
}


-(CLLocationCoordinate2D) gps {

    if ( !_latGps ) {
        
        self.coordGPS = kCLLocationCoordinate2DInvalid;
        self.latGps = @"";  // aready compute
        
        NSDictionary *locationJSON = [self.datas valueForKeyPath:@"venue.location"];
        NSDictionary *pointJSON = [locationJSON objectForKey:@"geo:point"];
        
        if (pointJSON) {
            
            self.latGps = [pointJSON objectForKey:@"geo:lat"];
            self.lonGps = [pointJSON objectForKey:@"geo:long"];
            
            if (self.latGps.length>0 && self.lonGps.length>0) {
                CLLocationDegrees latitude = self.latGps.doubleValue;
                CLLocationDegrees longitude = self.lonGps.doubleValue;
                self.coordGPS = CLLocationCoordinate2DMake(latitude, longitude);
            }
        }
    }

    return _coordGPS;
}

-(NSString *) city {
    
    if (!_city) {
        
        self.city = [self.datas valueForKeyPath:@"venue.location.city"];
    }
    
    return _city;
}

-(NSString *) country {
    
    if (!_country) {
        
        self.country = [self.datas valueForKeyPath:@"venue.location.country"];
    }
    
    return _country;
}

-(NSString *) webSite {
    
    if (!_webSite) {
        
        self.webSite = [self.datas valueForKeyPath:@"venue.website"];
    }
    
    return _webSite;
}

-(NSString *) phoneNumber {
    
    if (!_phoneNumber) {
        
        self.phoneNumber = [self.datas valueForKeyPath:@"venue.phonenumber"];
    }
    
    return _phoneNumber;
}

-(NSString *) urlImage {
    
    if (!_urlImage) {
        
        NSArray *images = [self.datas valueForKeyPath:@"image"];
        
        self.urlImage = [self urlImageFromJSON:images SizeName:kSizeMega];

        if (_urlImage == nil) {
            self.urlImage = [self urlImageFromJSON:images SizeName:kSizeExtraLarge];
        }
        
        if (_urlImage == nil) {
            self.urlImage = [self urlImageFromJSON:images SizeName:kSizeLarge];
        }
    }
    
    return _urlImage;
}


-(NSString *)startDateString {
    
    if (!_startDateString) {
        
        self.startDateString = [self.datas valueForKeyPath:@"startDate"];
    }
    
    return _startDateString;
}

-(NSDate *) startDate {
    
    if (!_startDate) {
        
        self.startDate = [[HPLastFm sharedInstance] transformValue:[self startDateString] intoClass:@"NSDate"];
    }
    
    return _startDate;
}

-(NSString *)endDateString {
    
    if (!_endDateString) {
        
        self.endDateString = [self.datas valueForKeyPath:@"endDate"];
    }
    
    return _endDateString;
}

-(NSDate *) endDate {
    
    if (!_endDate) {
        
        self.endDate = [[HPLastFm sharedInstance] transformValue:[self endDateString] intoClass:@"NSDate"];
    }
    
    return _endDate;
}

-(BOOL)cancelled {
    
    if (!_cancelledNumber) {
        
        self.cancelledNumber = [self.datas valueForKeyPath:@"cancelled"];
    }
    
    return self.cancelledNumber.boolValue;
}


@end
