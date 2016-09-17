//
//  ViewController.m
//  Chuchi
//
//  Created by Angel Rodriguez junquera on 17/09/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "ViewController.h"
#import "Reminder.h"
#import "Product.h"
@import FirebaseDatabase;
#import <INTULocationManager.h>
#import <GeoFire.h>
#import "ReminderCreatorService.h"
@import UserNotifications;
#import "AvailabilityCheckService.h"
#import "User.h"
#import "ProductService.h"

@interface ViewController ()

@property FIRDatabaseReference* reference;
@property NSMutableArray<Reminder*>* reminders;
@property GeoFire* geoFire;
@property GFCircleQuery *circleQuery;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadRemindersForUser];
    [self startMonitoringUserLocation];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"Notification permissions %d with error %@", granted, error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadRemindersForUser{
    __weak typeof(self) welf = self;
    self.reference = [[[[[FIRDatabase database] reference] child:@"user"] child:User.sharedInstance.name] child:@"reminders"];
    [self.reference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"Receveid %@", snapshot.value);
        if (snapshot.value == [NSNull null]) {
            return;
        }
        welf.reminders = [NSMutableArray new];
        NSDictionary* reminders = snapshot.value;
        for (NSString* key in reminders.allKeys) {
            NSDictionary* reminderDictionary = reminders[key];
            Reminder* reminder = [[Reminder alloc] initWithDictionary:reminderDictionary];
            [welf.reminders addObject:reminder];
            [[ProductService sharedInstance] loadImagesForProduct:reminder.product withCompletionBlock:^(BOOL success) {
                if (success) {
                    [welf showNotificationForReminder:reminder fromShopName:@"Best shop ever"];
                }
            }];
        }
    }];
}

- (void)startMonitoringUserLocation{
    __weak typeof(self) welf = self;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        [welf startMonitoringGeoFireWithLocation:currentLocation];
    }];
}

- (void)startMonitoringGeoFireWithLocation:(CLLocation*)currentLocation{
    __weak typeof(self) welf = self;
    
    if (!self.circleQuery) {
        self.circleQuery = [self.geoFire queryAtLocation:currentLocation withRadius:1];
    } else {
        self.circleQuery.center = currentLocation;
    }
    
    [self.circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        [welf checkIfAnyProductAvailableAtStoreWithKey:key];
    }];
    
    [self.circleQuery observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        
    }];
    
    [self.circleQuery observeReadyWithBlock:^{
        
    }];
}

- (void)checkIfAnyProductAvailableAtStoreWithKey:(NSString*)key{
    for (Reminder* reminder in self.reminders) {
        if (reminder.product && !reminder.reminderFired) {
            [[AvailabilityCheckService sharedInstance] checkIfProduct:reminder.product isAvailableAtStoreWithKey:key withCompletionBlock:^(BOOL success, NSString * shopName) {
                NSLog(@"FOUND %d %@ at %@(%@)", success, reminder.product.EANCode, shopName, key);
                if (!success) {
                    return;
                }
                if (reminder.reminderFired) {
                    return;
                }
                reminder.reminderFired = YES;
                [[ProductService sharedInstance] loadImagesForProduct:reminder.product withCompletionBlock:^(BOOL success) {
                    if (success) {
                        [self showNotificationForReminder:reminder fromShopName:shopName];
                    }
                }];
            }];
        }
    }
}

- (void)showNotificationForReminder:(Reminder*)reminder fromShopName:(NSString*)shopName{
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Shopping request";
    content.body = [NSString stringWithFormat:@"%@ would like you to buy %@ from the %@ nearby", reminder.reminderCreator, reminder.product.name, shopName];
    content.sound = [UNNotificationSound defaultSound];
    
    if (reminder.product.URLToLocalImage) {
        NSError* error;
        UNNotificationAttachment* image = [UNNotificationAttachment attachmentWithIdentifier:@"image" URL:reminder.product.URLToLocalImage options:@{} error:&error];
        content.attachments = @[image];
    }
    
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:1 repeats:NO];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"ReminderForShopping"
                                                                          content:content trigger:trigger];
    // Schedule the notification.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"=========== Error %@", error);
    }];
}
@end
