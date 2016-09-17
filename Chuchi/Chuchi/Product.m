//
//  Product.m
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "Product.h"
#import <AFHTTPRequestOperation.h>

@interface Product()

@property (readwrite) NSString* EANCode;
@property (readwrite) NSString* name;
@property (readwrite) NSURL* URLToRemoteImage;

@end


@implementation Product

- (instancetype)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    if (self) {
        self.EANCode = dictionary[NSStringFromSelector(@selector(EANCode))];
        self.name = dictionary[NSStringFromSelector(@selector(name))];
        self.URLToRemoteImage = [NSURL URLWithString:dictionary[@"imageURL"]];
    }
    return self;
}
@end
