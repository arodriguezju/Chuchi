//
//  Reminder.h
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Product;

@interface Reminder : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@property (readonly) NSString* reminderCreator;
@property (readonly) BOOL reminderFired;
@property (readonly) Product* product;

@end
