//
//  AvailabilityCheckService.h
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Product;

@interface AvailabilityCheckService : NSObject
+ (instancetype)sharedInstance;
- (void)checkIfProduct:(Product*)product isAvailableAtStoreWithKey:(NSString*)key withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock;

@end
