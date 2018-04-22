//
//  ADNewsDetailController.h
//  ADNews
//
//  Created by Александр Дудырев on 22.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADNewsDetailController : UIViewController

- (instancetype)initWithNews:(DBNews *)news;

- (void)configureWithNews:(DBNews *)news;

@end
