//
//  HPLastFmMapperPaging.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 15/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapperPaging.h"


@interface HPLastFmMapperPaging ()

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *location;

@property (nonatomic, strong) NSNumber *pageNumber;
@property (nonatomic, strong) NSNumber *perPageNumber;
@property (nonatomic, strong) NSNumber *totalNumber;
@property (nonatomic, strong) NSNumber *totalPagesNumber;

@end

@implementation HPLastFmMapperPaging

-(NSString *) artist {
    
    if (!_artist) {
        
        NSDictionary *events = [self.datas objectForKey:@"events"];
        NSDictionary *attr = [events objectForKey:@"@attr"];
        self.artist = [attr objectForKey:@"artist"];
        if (_artist == nil) {
            self.artist = @"";
        }
    }
    
    return _artist;
}

-(NSString *) location {
    
    if (!_location) {
        
        NSDictionary *events = [self.datas objectForKey:@"events"];
        NSDictionary *attr = [events objectForKey:@"@attr"];
        self.location = [attr objectForKey:@"location"];
        if (_location == nil) {
            self.location = @"";
        }
    }
    
    return _location;
}


-(NSInteger) page {
    
    if (!_pageNumber) {
        
        NSDictionary *events = [self.datas objectForKey:@"events"];
        NSDictionary *attr = [events objectForKey:@"@attr"];
        self.pageNumber = [attr objectForKey:@"page"];
    }
    
    return self.pageNumber.integerValue;
}

-(NSInteger) perPage {
    
    if (!_perPageNumber) {
        
        NSDictionary *events = [self.datas objectForKey:@"events"];
        NSDictionary *attr = [events objectForKey:@"@attr"];
        self.perPageNumber = [attr objectForKey:@"perPage"];
    }
    
    return _perPageNumber.integerValue;
}

-(NSInteger) total {
    
    if (!_totalNumber) {
        
        NSDictionary *events = [self.datas objectForKey:@"events"];
        NSDictionary *attr = [events objectForKey:@"@attr"];
        self.totalNumber = [attr objectForKey:@"total"];
    }
    
    return _totalNumber.integerValue;
}

-(NSInteger) totalPages {
    
    if (!_totalPagesNumber) {
        
        NSDictionary *events = [self.datas objectForKey:@"events"];
        NSDictionary *attr = [events objectForKey:@"@attr"];
        self.totalPagesNumber = [attr objectForKey:@"totalPages"];
    }
    
    return self.totalPagesNumber.integerValue;
}

@end
