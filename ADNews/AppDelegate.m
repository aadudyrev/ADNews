//
//  AppDelegate.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "AppDelegate.h"
#import "ADTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ADTabBarController *mainController = [[ADTabBarController alloc] init];
    self.window.rootViewController = mainController;
    [self.window makeKeyAndVisible];
    
    [self checkResetStatus];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self checkResetStatus];
    [[ADCoreDataManager shared] downloadNewsForType:DBNewsTypeTopHeadlines withOptions:nil];
}

- (void)checkResetStatus {
    NSString *resetKey = @"ADNewsResetDB";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [userDefaults valueForKey:resetKey];
    BOOL reset = [number boolValue];
    if (reset) {
        [[ADCoreDataManager shared] deleteAllObjectsForEntityName:NSStringFromClass([DBNews class])];
        [[ADCoreDataManager shared] deleteAllObjectsForEntityName:NSStringFromClass([DBSource class])];
        [[ADCoreDataManager shared] deleteAllObjectsForEntityName:NSStringFromClass([DBDocument class])];
        
        [userDefaults setBool:!reset forKey:resetKey];
    }
}

@end
