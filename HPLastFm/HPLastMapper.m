//
//  HPLastMapper.m
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 12/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import "HPLastMapper.h"

@interface HPLastMapper()

@property (nonatomic, strong) NSDictionary *datas;

@end

@implementation HPLastMapper

-(id)initWithDictionary:(NSDictionary *)dico {
    
    if ((self = [super init])) {
    
        self.datas = dico;
    }
    
    return self;
}


+(NSString *) stringByStrippingHTML:(NSString *)original {
    
    NSRange r;
    
    NSString *s = [original copy];
    
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    
    return s;
}


@end
