//
//  HPLastFmMapper_getInfoForArtist.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 12/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapper_getInfoForArtist.h"
#import <NSString+HTML.h>

@interface HPLastFmMapper_getInfoForArtist ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *urlImageSmall;
@property (nonatomic, strong) NSString *urlImageMedium;
@property (nonatomic, strong) NSString *urlImageLarge;
@property (nonatomic, strong) NSString *urlImageMega;
@property (nonatomic, assign) BOOL onTour;
@property (nonatomic, strong) NSArray *tags; // Array of NSString
@property (nonatomic, strong) NSArray *similarArtists;  // Array of NSString

@end

@implementation HPLastFmMapper_getInfoForArtist

-(NSString *) name {

    if (!_name) {
        
        self.name = [self.datas valueForKeyPath:@"artist.name"];
    }
    
    return _name;
}

-(NSString *) bio {
    
    if (!_bio) {
        
        NSString *bioJson = [self.datas valueForKeyPath:@"artist.bio.content"];
        
        // remove all html tag
        self.bio = [bioJson stringByConvertingHTMLToPlainText];
    }
    
    return _bio;
}

-(NSString *) urlImageSmall {
    
    if (!_urlImageSmall) {
        
        NSArray *images = [self.datas valueForKeyPath:@"artist.image"];
        
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *img = obj;
            
            NSString *sizeImg = [img valueForKey:@"size"];
            
            if ([sizeImg isEqualToString:@"small"]) {

                self.urlImageSmall = [img valueForKey:@"#text"];
                *stop = YES;
            }
        }];
    }
    
    return _urlImageSmall;
}

-(NSString *) urlImageMedium {
    
    if (!_urlImageMedium) {
        
        NSArray *images = [self.datas valueForKeyPath:@"artist.image"];
        
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *img = obj;
            
            NSString *sizeImg = [img valueForKey:@"size"];
            
            if ([sizeImg isEqualToString:@"medium"]) {
                
                self.urlImageMedium = [img valueForKey:@"#text"];
                *stop = YES;
            }
        }];
    }
    
    return _urlImageMedium;
}

-(NSString *) urlImageLarge {
    
    if (!_urlImageLarge) {
        
        NSArray *images = [self.datas valueForKeyPath:@"artist.image"];
        
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *img = obj;
            
            NSString *sizeImg = [img valueForKey:@"size"];
            
            if ([sizeImg isEqualToString:@"large"]) {
                
                self.urlImageLarge = [img valueForKey:@"#text"];
                *stop = YES;
            }
        }];
    }
    
    return _urlImageLarge;
}

-(NSString *) urlImageMega {
    
    if (!_urlImageMega) {
        
        NSArray *images = [self.datas valueForKeyPath:@"artist.image"];
        
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *img = obj;
            
            NSString *sizeImg = [img valueForKey:@"size"];
            
            if ([sizeImg isEqualToString:@"mega"]) {
                
                self.urlImageMega = [img valueForKey:@"#text"];
                *stop = YES;
            }
        }];
    }
    
    return _urlImageMega;
}

-(BOOL) onTour {
    
    NSNumber *onTourJSON = [self.datas valueForKeyPath:@"artist.ontour"];
    self.onTour = onTourJSON.boolValue;
    return _onTour;
}


@end
