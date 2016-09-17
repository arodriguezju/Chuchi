//
//  ProductService.h
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Product;

@interface ProductService : NSObject
+ (instancetype)sharedInstance;
- (void)loadImagesForProduct:(Product*)product withCompletionBlock:(void (^)(BOOL))completionBlock;
@end
