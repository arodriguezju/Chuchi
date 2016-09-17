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
    NSString* urlFormat = @"http://asdasdadaasdadas/%@/%@";
    NSString* urlString = [NSString stringWithFormat:urlFormat, key, product.EANCode];
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL success = responseObject[@"success"];
        if (success) {
            NSURLRequest *request = [NSURLRequest requestWithURL:product.URLToRemoteImage];
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
            requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //NSLog(@"Response: %@", responseObject);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documents = [paths objectAtIndex:0];
                NSString* filename = [NSString stringWithFormat:@"%@.%@", product.EANCode, product.URLToRemoteImage.pathExtension];
                NSString *finalPath = [documents stringByAppendingPathComponent: filename];
                [[operation responseData] writeToFile:finalPath atomically:YES];
                product.URLToLocalImage = [NSURL fileURLWithPath:finalPath];
                completionBlock(YES, responseObject[@"shopName"]);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Image error: %@ - %@", error, product.URLToRemoteImage);
                completionBlock(NO, Nil);
            }];
            [requestOperation start];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO, Nil);
    }];
    [operation start];
}

@end
