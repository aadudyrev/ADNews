//
//  ADTabBarController.m
//  ADNews
//
//  Created by Александр Дудырев on 23.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "ADTabBarController.h"

#import "ADMainController.h"
#import "ADSourcesController.h"

@interface ADTabBarController ()

@property (nonatomic, strong) NSArray <UIViewController <ADTabBarProtocol> *> *controllers;

@end

@implementation ADTabBarController

- (instancetype)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *viewControllers = @[
                                 [[ADMainController alloc] initWithType:DBNewsTypeTopHeadlines],
                                 [[ADMainController alloc] initWithType:DBNewsTypeEverything],
                                 [[ADSourcesController alloc] init],
                                 ];
    
    [self setViewControllers:viewControllers];
    for (NSInteger i = 0; i < self.tabBar.items.count; i++) {
        UIViewController <ADTabBarProtocol> *vc = viewControllers[i];
        UITabBarItem *item = self.tabBar.items[i];
        item.image = [vc tabBarImage];
        item.title = [vc tabBarTitle];
    }
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:viewControllers.count];
    for (UIViewController <ADTabBarProtocol> *vc in viewControllers) {
        if ([vc embeddedInNavigationController]) {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
            [mArr addObject:navController];
        } else {
            [mArr addObject:vc];
        }
    }
    
    [super setViewControllers:[NSArray arrayWithArray:mArr]];
}

@end
