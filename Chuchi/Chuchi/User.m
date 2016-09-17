//
//  User.m
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "User.h"

@implementation User

+ (instancetype)sharedInstance{
    static User* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [User new];
    });
    return instance;
}

- (NSString*)name{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UserName"];
}
@end
