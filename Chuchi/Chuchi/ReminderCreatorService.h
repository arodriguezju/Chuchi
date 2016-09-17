//
//  ReminderCreatorService.h
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reminder;

@interface ReminderCreatorService : NSObject
+ (instancetype)sharedInstance;
- (void)createReminderForUser:(NSString*)user withMessage:(NSString*)message forProductWithEANNumber:(NSString*)EANNumber createdByReminderCreator:(NSString*)reminderCreator withCompletionBlock:(void (^)(BOOL))completionBlock;
- (void)removeReminder:(Reminder*)reminder;
@end
