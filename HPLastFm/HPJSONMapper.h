//
//  HPLastMapper.h
//  HPLastFm
//
//  Created by Hervé PEROTEAU on 12/02/2014.
//  Copyright (c) 2014 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSizeMedium @"medium"
#define kSizeLarge @"large"
#define kSizeExtraLarge @"extralarge"
#define kSizeMega @"mega"

@interface HPJSONMapper : NSObject

@property (nonatomic, readonly) NSDictionary *datas;

-(id)initWithDictionary:(NSDictionary *)dico;
-(NSString *) urlImageFromJSON:(NSArray *)imagesJSON SizeName:(NSString *)sizeName;

+(NSString *) stringByStrippingHTML:(NSString *)original;

@end
