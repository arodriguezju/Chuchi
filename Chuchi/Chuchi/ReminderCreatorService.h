//
//  ReminderCreatorService.h
//  Chuchi
//
//  Created by Silviu Andrica on 9/17/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReminderCreatorService : NSObject
+ (instancetype)sharedInstance;
- (void)createReminderForUser:(NSString*)user forProductWithEANNumber:(NSString*)EANNumber createdByReminderCreator:(NSString*)reminderCreator withCompletionBlock:(void (^)(BOOL))completionBlock;
@end
