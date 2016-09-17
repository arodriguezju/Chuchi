//
//  AvailabilityCheckService.m
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "AvailabilityCheckService.h"
#import <AFHTTPRequestOperation.h>
#import "Product.h"

@implementation AvailabilityCheckService

+ (instancetype)sharedInstance{
    static AvailabilityCheckService* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AvailabilityCheckService new];
    });
    return instance;
}

- (void)checkIfProduct:(Product*)product isAvailableAtStoreWithKey:(NSString*)key withCompletionBlock:(void (^)(BOOL,NSString*))completionBlock{
    NSString* urlFormat = @"http://euve250296.serverprofi24.net:3000/items/%@/%@";
    NSString* urlString = [NSString stringWithFormat:urlFormat, product.EANCode, key];
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* storeName = responseObject[@"storeName"];
        completionBlock(YES, storeName);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO, Nil);
    }];
    [operation start];
}

@end
