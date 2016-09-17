//
//  ReminderCreatorService.m
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "ReminderCreatorService.h"
@import FirebaseDatabase;
@import Firebase;
#import <AFHTTPRequestOperation.h>

@implementation ReminderCreatorService

+ (instancetype)sharedInstance{
    static ReminderCreatorService* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ReminderCreatorService new];
    });
    return instance;
}

- (void)createReminderForUser:(NSString*)user withMessage:(NSString*)message forProductWithEANNumber:(NSString*)EANNumber createdByReminderCreator:(NSString*)reminderCreator withCompletionBlock:(void (^)(BOOL))completionBlock{
    NSString* urlFormat = @"https://api.siroop.ch/product/ean/%@/?apikey=8ccd66bb1265472cbf8bed4458af4b07";
    NSString* urlString = [NSString stringWithFormat:urlFormat, EANNumber];
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* result = responseObject;
        if (!result.count) {
            completionBlock(NO);
            return;
        }
        NSDictionary* firstResult = result.firstObject;
        NSString* name = firstResult[@"name"];
        NSString* imageURL = firstResult[@"images"][@"highres"];
        
        FIRDatabaseReference* reference = [[[[[FIRDatabase database] reference] child:@"user"] child:user] child:@"reminders"];
        NSDictionary* dictionary = @{@"message" : message, @"reminderFired" : @(NO), @"reminderCreator" : reminderCreator, @"product" : @{@"EANCode" : EANNumber, @"name" : name, @"imageURL" : imageURL}};
        [[reference childByAutoId] setValue:dictionary withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            NSLog(@"Done with error %@", error);
            completionBlock(error == Nil);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO);
    }];
    [operation start];
}

@end
