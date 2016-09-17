//
//  Message.m
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "Message.h"

@implementation Message
+ (instancetype)sharedInstance{
    static Message* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [Message new];
    });
    return instance;
}


@end
