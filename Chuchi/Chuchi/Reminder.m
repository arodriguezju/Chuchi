//
//  Reminder.m
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "Reminder.h"
#import "Product.h"

@interface Reminder()

@property (readwrite) NSString* reminderCreator;
@property (readwrite) BOOL reminderFired;
@property (readwrite) Product* product;

@end
@implementation Reminder

- (instancetype)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    if (self) {
        self.reminderFired = [dictionary[NSStringFromSelector(@selector(reminderFired))] boolValue];
        self.reminderCreator = dictionary[NSStringFromSelector(@selector(reminderCreator))];
        self.product = [[Product alloc] initWithDictionary:dictionary[NSStringFromSelector(@selector(product))]];
    }
    return self;
}

@end
