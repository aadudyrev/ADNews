//
//  ADTabBarProtocol.h
//  ADNews
//
//  Created by Александр Дудырев on 24.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ADTabBarProtocol
@required
- (BOOL)embeddedInNavigationController;
- (UIImage *)tabBarImage;
- (NSString *)tabBarTitle;
@end
