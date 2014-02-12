//
//  HPLastMapper.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 12/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPLastMapper : NSObject

-(id)initWithDictionary:(NSDictionary *)dico;

@property (nonatomic, readonly) NSDictionary *datas;

+(NSString *) stringByStrippingHTML:(NSString *)original;

@end
