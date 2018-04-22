//
//  ADLabel.h
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets insets;

- (CGFloat)heightForWidth:(CGFloat)width;

@end
