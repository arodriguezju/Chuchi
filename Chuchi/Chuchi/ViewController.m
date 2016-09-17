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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadRemindersForUser{
    __weak typeof(self) welf = self;
    NSString* currentUser = @"Silviu";
    self.reference = [[[[[FIRDatabase database] reference] child:@"user"] child:currentUser] child:@"reminders"];
    [self.reference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"Receveid %@", snapshot.value);
        welf.reminders = [NSMutableArray new];
        NSDictionary* reminders = snapshot.value;
        for (NSString* key in reminders.allKeys) {
            NSDictionary* reminderDictionary = reminders[key];
            Reminder* reminder = [[Reminder alloc] initWithDictionary:reminderDictionary];
            [welf.reminders addObject:reminder];
        }
    }];
}

- (void)startMonitoringUserLocation{
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        
    }];
}

- (void)startMonitoringGeoFireWithLocation:(CLLocation*)currentLocation{
    __weak typeof(self) welf = self;

    self.circleQuery = [self.geoFire queryAtLocation:currentLocation withRadius:1];
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
        if (reminder.product) {
            [self checkIfProductWithEAN:reminder.product.EANCode isAvailableAtStoreWithKey:key withCallback:^(BOOL param) {
                NSLog(@"FOUND %d %@ at %@", param, reminder.product.EANCode, key);
            }];
        }
    }
}

- (void)checkIfProductWithEAN:(NSString*)EANCode isAvailableAtStoreWithKey:(NSString*)key withCallback:(void (^)(BOOL))completionBlock{
    completionBlock(YES);
}
@end
