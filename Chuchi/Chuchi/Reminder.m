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

@property (readwrite) NSString* message;
@property (readwrite) NSString* reminderCreator;
@property (readwrite) Product* product;
@property (readwrite) NSString* reminderId;

@end
@implementation Reminder

- (instancetype)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    if (self) {
        self.reminderId = dictionary[NSStringFromSelector(@selector(reminderId))];
        self.reminderCreator = dictionary[NSStringFromSelector(@selector(reminderCreator))];
        self.message = dictionary[NSStringFromSelector(@selector(message))];
        self.product = [[Product alloc] initWithDictionary:dictionary[NSStringFromSelector(@selector(product))]];
    }
    return self;
}

@end
