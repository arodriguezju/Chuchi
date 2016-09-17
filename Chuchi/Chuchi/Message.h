//
//  Message.h
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

+ (instancetype)sharedInstance;
@property NSString* recipient;
@property NSString* message;

@end
