//
//  Product.h
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@property (readonly) NSString* EANCode;
@property (readonly) NSString* name;
@property NSURL* URLToLocalImage;
@property (readonly) NSURL* URLToRemoteImage;

@end
