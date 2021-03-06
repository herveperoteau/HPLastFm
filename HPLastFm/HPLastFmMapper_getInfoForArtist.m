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
@property (nonatomic, strong) NSString *urlImage;
@property (nonatomic, strong) NSString *urlImageMedium;
@property (nonatomic, strong) NSString *urlImageLarge;
@property (nonatomic, strong) NSString *urlImageMega;
@property (nonatomic, assign) NSNumber *onTourNumber;
@property (nonatomic, strong) NSArray *tags; // Array of NSString
@property (nonatomic, strong) NSArray *similarArtists;  // Array of NSString
@property (nonatomic, strong) NSNumber *isValidNumber;

@end

@implementation HPLastFmMapper_getInfoForArtist

-(NSString *) name {

    if (!_name) {
        
        NSString *jsonString = [self.datas valueForKeyPath:@"artist.name"];
        self.name = [jsonString stringByConvertingHTMLToPlainText];
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

-(NSString *) urlImage {
    
    if ( ![self isValid] ) {
        return nil;
    }

    NSString *result = [self urlImageMega];
    
    if (result.length == 0) {
        result = [self urlImageLarge];
    }

    if (result.length == 0) {
        result = [self urlImageMedium];
    }
    
    return result;
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
    
    if (!_onTourNumber) {

        self.onTourNumber = [self.datas valueForKeyPath:@"artist.ontour"];
    }
    
    return self.onTourNumber.boolValue;
}

-(NSArray *)tags {

    if (!_tags) {
        
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        
        NSArray *tags = [self.datas valueForKeyPath:@"artist.tags.tag"];
        
        [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *tag = obj;
            
            NSString *jsonString = [tag valueForKey:@"name"];
            NSString *name = [jsonString stringByConvertingHTMLToPlainText];

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

        id artists = nil;
        
        @try {
            artists = [self.datas valueForKeyPath:@"artist.similar.artist"];
        }
        @catch (NSException *exception) {
            // invalid artist
            return nil;
        }
        
        // Only one item
        if ([artists isKindOfClass:NSDictionary.class]) {
            NSArray *tmp = [NSArray arrayWithObject:artists];
            artists = tmp;
        }
        
        [artists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *artist = obj;

            NSString *jsonString = [artist valueForKey:@"name"];
            NSString *name = [jsonString stringByConvertingHTMLToPlainText];
            
            if (name) {
                
                NSMutableDictionary *similar = [[NSMutableDictionary alloc] init];
                
                [similar setObject:name forKey:kSimilarArtistName];
                
                NSArray *images = [artist valueForKey:@"image"];

                if (images) {
                    for (NSString *key in @[kSizeMega, kSizeLarge, kSizeMedium]) {
                        NSString *urlImage = [self urlImageFromJSON:images SizeName:key];
                        if (urlImage) {
                            [similar setObject:urlImage forKey:kSimilarArtistImage];
                            break;
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

-(BOOL) isValid {
    
    if (!_isValidNumber) {
        
        NSString *urlMega = [self urlImageMega];
        
        _isValidNumber = [NSNumber numberWithBool:YES];
        
        if ( [urlMega rangeOfString:@"stats+clean"].location != NSNotFound ) {
            // "http://userserve-ak.last.fm/serve/_/72728954/Reprise+des+Negociations+Keep+stats+clean.png";
            _isValidNumber = [NSNumber numberWithBool:NO];
        }
        
        if (_isValidNumber.boolValue) {
            // check if json complete
            NSArray *test = self.similarArtists;
            if (test == nil) {
                _isValidNumber = [NSNumber numberWithBool:NO];
            }
        }
    }
    
    return self.isValidNumber.boolValue;
}


@end
