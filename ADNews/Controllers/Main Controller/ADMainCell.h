//
//  ADMainCell.h
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADMainCell : UITableViewCell


- (void)configureWithNews:(DBNews *)news;

- (CGFloat)getHeightForWidth:(CGFloat)width;

@end
