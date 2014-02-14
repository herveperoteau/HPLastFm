//
//  HPLastFmMapper_getInfoForAlbum.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 13/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastFmMapper_getInfoForAlbum.h"
#import <NSString+HTML.h>

@interface HPLastFmMapper_getInfoForAlbum ()

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *urlImageMedium;
@property (nonatomic, strong) NSString *urlImageLarge;
@property (nonatomic, strong) NSString *urlImageMega;
@property (nonatomic, strong) NSString *wiki;

@end

@implementation HPLastFmMapper_getInfoForAlbum

-(NSString *) artist {
    
    if (!_artist) {
        
        self.artist = [self.datas valueForKeyPath:@"album.artist"];
    }
    
    return _artist;
}

-(NSString *) title {
    
    if (!_title) {
        
        self.title = [self.datas valueForKeyPath:@"album.name"];
    }
    
    return _title;
}

-(NSString *) year {
    
    if (!_year) {
        
        NSString *dateReleaseStr = [self.datas valueForKeyPath:@"album.releasedate"];
        
        //"    19 Nov 2012, 00:00"
        NSRange comma = [dateReleaseStr rangeOfString:@", "];
        
        if (comma.location >= 4) {
            
            self.year = [dateReleaseStr substringWithRange:NSMakeRange(comma.location-4, 4)];
        }
    }
    
    return _year;
}


-(NSString *) urlImageMedium {
    
    if (!_urlImageMedium) {
        
        NSArray *images = [self.datas valueForKeyPath:@"album.image"];
        self.urlImageMedium = [self urlImageFromJSON:images SizeName:kSizeMedium];
    }
    
    return _urlImageMedium;
}

-(NSString *) urlImageLarge {
    
    if (!_urlImageLarge) {
        
        NSArray *images = [self.datas valueForKeyPath:@"album.image"];
        self.urlImageLarge = [self urlImageFromJSON:images SizeName:kSizeLarge];
    }
    
    return _urlImageLarge;
}

-(NSString *) urlImageMega {
    
    if (!_urlImageMega) {
        
        NSArray *images = [self.datas valueForKeyPath:@"album.image"];
        self.urlImageMega = [self urlImageFromJSON:images SizeName:kSizeMega];
    }
    
    return _urlImageMega;
}

-(NSString *) wiki {
    
    if (!_wiki) {
        
        NSString *wikiJson = [self.datas valueForKeyPath:@"album.wiki.content"];
        
        // remove all html tag
        self.wiki = [wikiJson stringByConvertingHTMLToPlainText];

    }
    
    return _wiki;
}

@end
