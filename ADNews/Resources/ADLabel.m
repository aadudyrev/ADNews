//
//  ADLabel.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "ADLabel.h"

@implementation ADLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.insets = UIEdgeInsetsMake(5, 5, 5, 5);
        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.font = [UIFont italicSystemFontOfSize:12.f];
    }
    return self;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    if (self.attributedText == nil) {
        return 0.f;
    }
    width -= widthForInsets(self.insets);
    CGSize size = CGSizeMake(width, CGFLOAT_MAX);
    CGRect rect = [self.attributedText boundingRectWithSize:size
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics
                                                    context:nil];
    return ceil(CGRectGetHeight(rect) + heightForInsets(self.insets));
}

- (void)drawTextInRect:(CGRect)rect {
    rect = UIEdgeInsetsInsetRect(rect, self.insets);
    [super drawTextInRect:rect];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
