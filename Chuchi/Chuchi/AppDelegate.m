//
//  AppDelegate.m
//  Chuchi
//
//  Created by Angel Rodriguez junquera on 17/09/16.
//  Copyright © 2016 angel. All rights reserved.
//

#import "AppDelegate.h"
@import Firebase;
@import UserNotifications;
@import MapKit;
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>
#import "Message.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [SBSLicense setAppKey:@"ht3TvoRueMHxg1vCcoGPOGder7wI+J4RtqUvlCuBsh0"];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    CLLocationDegrees latitude = [response.notification.request.content.userInfo[@"latitude"] doubleValue];
    CLLocationDegrees longitude = [response.notification.request.content.userInfo[@"longitude"] doubleValue];
    
    MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];

    MKMapItem* destinationPoint;
    destinationPoint = [[MKMapItem alloc] initWithPlacemark: [[MKPlacemark alloc] initWithPlacemark:placemark]];
    destinationPoint.name = response.notification.request.content.userInfo[@"shopName"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [destinationPoint openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking}];
    });
    completionHandler();
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler{
    NSLog(@"<<<<<=======|========>>>>> %@", userActivity.userInfo);
    
    [Message sharedInstance].recipient = userActivity.userInfo[NSStringFromSelector(@selector(recipient))];
    [Message sharedInstance].message = userActivity.userInfo[NSStringFromSelector(@selector(message))];
    
    return YES;
}
@end
