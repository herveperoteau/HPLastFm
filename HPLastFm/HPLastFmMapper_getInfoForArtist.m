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

-(NSString *) urlImageMedium {
    
    if (!_urlImageMedium) {
        
        NSArray *images = [self.datas valueForKeyPath:@"artist.image"];
        self.urlImageMedium = [self urlImageFromJSON:images SizeName:kSizeMedium];
    }
    
    return _urlImageMedium;
}

-(NSString *) urlImageLarge {
    
    if (!_urlImageLarge) {
        
        NSArray *images = [self.datas valueForKeyPath:@"artist.image"];
        self.urlImageLarge = [self urlImageFromJSON:images SizeName:kSizeLarge];
    }
    
    return _urlImageLarge;
}

-(NSString *) urlImageMega {
    
    if (!_urlImageMega) {
        
        NSArray *images = [self.datas valueForKeyPath:@"artist.image"];
        self.urlImageMega = [self urlImageFromJSON:images SizeName:kSizeMega];
    }
    
    return _urlImageMega;
}

-(BOOL) onTour {
    
    NSNumber *onTourJSON = [self.datas valueForKeyPath:@"artist.ontour"];
    self.onTour = onTourJSON.boolValue;
    return _onTour;
}

-(NSArray *)tags {

    if (!_tags) {
        
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        
        NSArray *tags = [self.datas valueForKeyPath:@"artist.tags.tag"];
        
        [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *tag = obj;
            
            NSString *name = [tag valueForKey:@"name"];

            if (name) {
                
                [tmp addObject:name];
            }
        }];
        
        self.tags = [NSArray arrayWithArray:tmp];
    }
    
    return _tags;
}

-(NSArray *)similarArtists {
    
    if (!_similarArtists) {
        
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        
        NSArray *artists = [self.datas valueForKeyPath:@"artist.similar.artist"];
        
        [artists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *artist = obj;

            NSArray *name = [artist valueForKey:@"name"];
            
            if (name) {
                
                NSMutableDictionary *similar = [[NSMutableDictionary alloc] init];
                
                [similar setObject:name forKey:kSimilarArtistName];
                
                NSArray *images = [artist valueForKey:@"image"];

                if (images) {
                    for (NSString *key in @[kSizeMedium, kSizeLarge, kSizeMega]) {
                        NSString *urlImage = [self urlImageFromJSON:images SizeName:key];
                        if (urlImage) {
                            [similar setObject:urlImage forKey:key];
                        }
                    }
                }
                
                [tmp addObject:[NSDictionary dictionaryWithDictionary:similar]];
            }
        }];
        
        self.similarArtists = [NSArray arrayWithArray:tmp];
    }
    
    return _similarArtists;
}



@end
