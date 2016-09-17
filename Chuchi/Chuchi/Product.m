//
//  Product.m
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "Product.h"

@interface Product()

@property (readwrite) NSString* EANCode;

@end


@implementation Product

- (instancetype)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    if (self) {
        self.EANCode = dictionary[NSStringFromSelector(@selector(EANCode))];
    }
    return self;
}
@end
