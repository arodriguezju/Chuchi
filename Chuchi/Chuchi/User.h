//
//  User.h
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+ (instancetype)sharedInstance;

@property (readonly) NSString* name;

@end
