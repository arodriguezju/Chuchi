//
//  ProductService.m
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "ProductService.h"
#import "Product.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@implementation ProductService

+ (instancetype)sharedInstance{
    static ProductService* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ProductService new];
    });
    return instance;
}

- (void)loadImagesForProduct:(Product*)product withCompletionBlock:(void (^)(BOOL))completionBlock{
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
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@ - %@", error, product.URLToRemoteImage);
        completionBlock(NO);
    }];
    [requestOperation start];
}

@end
