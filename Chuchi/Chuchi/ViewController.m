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
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>
#import <MBProgressHUD.h>
#import "Message.h"

@interface ViewController ()  <SBSScanDelegate>

@property FIRDatabaseReference* reference;
@property NSMutableArray<Reminder*>* reminders;
@property GeoFire* geoFire;
@property GFCircleQuery *circleQuery;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet SBSBarcodePickerView *barcodeScannerView;
@property NSMutableSet* scannedBarcodes;
@property NSMutableSet* foundKeys;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    ref = [ref child:@"stores"];
    self.geoFire = [[GeoFire alloc] initWithFirebaseRef:ref];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadRemindersForUser];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"Notification permissions %d with error %@", granted, error);
    }];
    
    self.foundKeys = [NSMutableSet new];
    [self.barcodeScannerView setScanDelegate:self];
    
    self.scannedBarcodes = [NSMutableSet new];
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
        }
        [self startMonitoringUserLocation];
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
        self.circleQuery = [self.geoFire queryAtLocation:currentLocation withRadius:5];
    } else {
        self.circleQuery.center = currentLocation;
    }
    
    [self.circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Key found %@", key);
        if ([self.foundKeys containsObject:key]) {
            NSLog(@"Already processed %@", key);
            return;
        }
        [self.foundKeys addObject:key];
        [welf checkIfAnyProductAvailableAtStoreWithKey:key];
    }];
    
    [self.circleQuery observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        
    }];
    
    [self.circleQuery observeReadyWithBlock:^{
        
    }];
}

- (void)checkIfAnyProductAvailableAtStoreWithKey:(NSString*)key{
    for (Reminder* reminder in self.reminders) {
        if (reminder.product) {
            if (reminder.locationOfShopThatHasProduct) {
                return;
            }
            NSLog(@"Looking for %@ at %@", reminder.product.EANCode, key);
            [[AvailabilityCheckService sharedInstance] checkIfProduct:reminder.product isAvailableAtStoreWithKey:key withCompletionBlock:^(BOOL success, NSString * shopName) {
                NSLog(@"Looking for %@. FOUND %d at %@(%@)", reminder.product.EANCode, success, shopName, key);
                if (!success) {
                    return;
                }
                if (reminder.locationOfShopThatHasProduct) {
                    return;
                }
                [self.geoFire getLocationForKey:key withCallback:^(CLLocation *location, NSError *error) {
                    NSLog(@"Got location %@ for %@ with error %@", location, key, error);
                    if (location) {
                        if (reminder.locationOfShopThatHasProduct) {
                            return;
                        }
                        reminder.nameOfShopThatHasProduct = shopName;
                        reminder.locationOfShopThatHasProduct = location;
                        [[ProductService sharedInstance] loadImagesForProduct:reminder.product withCompletionBlock:^(BOOL success2) {
                            NSLog(@"Loaded images for %@ with success %d", reminder.product.EANCode, success2);
                            if (success) {
                                [self showNotificationForReminder:reminder];
                            }
                        }];
                    }
                }];
            }];
        }
    }
}

- (void)showNotificationForReminder:(Reminder*)reminder{
    NSLog(@"Showing notification for %@ - %@", reminder.message, reminder.product.name);
    [[ReminderCreatorService sharedInstance] removeReminder:reminder];
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Shopping request";
    content.body = [NSString stringWithFormat:@"%@ says: \"%@\": %@ from the %@ nearby.", reminder.reminderCreator, reminder.message, reminder.product.name, reminder.nameOfShopThatHasProduct];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"latitude" : @(reminder.locationOfShopThatHasProduct.coordinate.latitude), @"longitude" : @(reminder.locationOfShopThatHasProduct.coordinate.longitude), @"shopName" : reminder.nameOfShopThatHasProduct};
    
    if (reminder.product.URLToLocalImage) {
        NSError* error;
        UNNotificationAttachment* image = [UNNotificationAttachment attachmentWithIdentifier:@"image" URL:reminder.product.URLToLocalImage options:@{} error:&error];
        content.attachments = @[image];
    }
    
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:5 repeats:NO];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"ReminderForShopping"
                                                                          content:content trigger:trigger];
    // Schedule the notification.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"=========== Error %@", error);
    }];
}

- (void)didScanBarcode:(NSString *)barcode {
    
    if ([self.scannedBarcodes containsObject:barcode]) {
        return;
    }
    [self.scannedBarcodes addObject:barcode];
    [self.codeLabel setText:barcode];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString* forWhom = Message.sharedInstance.recipient;
    hud.label.text = [NSString stringWithFormat:@"Reminding %@ to %@", forWhom, Message.sharedInstance.message];
    hud.label.numberOfLines = 0;
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [[ReminderCreatorService sharedInstance] createReminderForUser:forWhom withMessage:Message.sharedInstance.message  forProductWithEANNumber:barcode createdByReminderCreator:User.sharedInstance.name withCompletionBlock:^(BOOL success) {
        if (success) {
            hud.label.text = @"Reminder created!";
        } else {
            [self.scannedBarcodes removeObject:barcode];
            hud.label.text = @"Failed";
        }
        hud.mode = MBProgressHUDModeText;
        
        NSLog(@"Created the reminder for %@ / %@ with %d", forWhom, barcode, success);
        [hud hideAnimated:YES afterDelay:3.0];
    }];
}

- (void)barcodePicker:(nonnull SBSBarcodePicker*)picker didScan:(nonnull SBSScanSession*)session{
    NSArray* recognized = session.newlyRecognizedCodes;
    if (recognized.count >0) {
        SBSCode *code = recognized.firstObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didScanBarcode:[code data] ];
        }) ;
    }
}

@end
