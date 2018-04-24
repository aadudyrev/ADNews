//
//  ADMainCell.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "ADMainCell.h"



@interface ADMainCell ()

@property (nonatomic, strong) DBNews *news;

@property (nonatomic, strong) ADLabel *newsTitleLabel;
@property (nonatomic, strong) ADLabel *newsAuthorLabel;
@property (nonatomic, strong) ADLabel *newsDescLabel;
@property (nonatomic, strong) UIImageView *newsImageView;

@end

@implementation ADMainCell
{
    UIEdgeInsets contentInsets;
    UIEdgeInsets imageInsets;
    UIEdgeInsets labelInsets;
    CGSize imageSize;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        contentInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        imageInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        labelInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        imageSize = CGSizeMake(70, 70);
        
        [self configure];
    }
    return self;
}

- (void)configure {
    self.newsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.newsImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.newsImageView];
    
    self.newsTitleLabel = [[ADLabel alloc] initWithFrame:CGRectZero];
    self.newsTitleLabel.insets = labelInsets;
    self.newsTitleLabel.font = [UIFont boldSystemFontOfSize:13.f];
    self.newsTitleLabel.textColor = [UIColor blackColor];
    self.newsTitleLabel.numberOfLines = 0;
    self.newsTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.newsTitleLabel];
    
    self.newsAuthorLabel = [[ADLabel alloc] initWithFrame:CGRectZero];
    self.newsAuthorLabel.insets = labelInsets;
    self.newsAuthorLabel.font = [UIFont italicSystemFontOfSize:10.f];
    self.newsAuthorLabel.textColor = [UIColor lightGrayColor];
    self.newsAuthorLabel.numberOfLines = 1;
    self.newsAuthorLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.newsAuthorLabel];
    
    self.newsDescLabel = [[ADLabel alloc] initWithFrame:CGRectZero];
    self.newsDescLabel.insets = labelInsets;
    self.newsDescLabel.font = [UIFont systemFontOfSize:13.f];
    self.newsDescLabel.textColor = [UIColor blackColor];
    self.newsDescLabel.numberOfLines = 2;
    self.newsDescLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.newsDescLabel];
}

- (void)configureWithNews:(DBNews *)news {
    self.news = news;
    
    self.newsTitleLabel.text = news.title;
    self.newsAuthorLabel.text = news.author;
    self.newsDescLabel.text = news.descr;
    
    self.newsImageView.image = nil;
}

- (CGFloat)getHeightForWidth:(CGFloat)width {
    width -= widthForInsets(contentInsets);
    CGFloat height = heightForInsets(contentInsets);
    CGFloat imageHeight = imageSize.height + heightForInsets(imageInsets);
    CGFloat rightLabelsHeight = 0.f;
    height += [self.newsDescLabel heightForWidth:width];
    width -= imageSize.width + widthForInsets(imageInsets);
    rightLabelsHeight += [self.newsTitleLabel heightForWidth:width];
    rightLabelsHeight += [self.newsAuthorLabel heightForWidth:width];
    height += MAX(imageHeight, rightLabelsHeight);
    
    return height;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, contentInsets);
    
    CGFloat x = CGRectGetMinX(bounds) + imageInsets.left;
    CGFloat y = CGRectGetMinY(bounds) + imageInsets.top;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    UIImage *newsImage = self.news.image.newsImage;
    UIImage *image = newsImage ? newsImage : [UIImage imageNamed:@"def-icon-news"];
    self.newsImageView.image = image;
    self.newsImageView.frame = CGRectMake(x, y, width, height);

    x += width + imageInsets.right;
    y = CGRectGetMinY(bounds);
    width = CGRectGetWidth(bounds) - width - widthForInsets(imageInsets);
    height = [self.newsTitleLabel heightForWidth:width];
    self.newsTitleLabel.frame = CGRectMake(x, y, width, height);
    
    y += height;
    height = [self.newsAuthorLabel heightForWidth:width];
    self.newsAuthorLabel.frame = CGRectMake(x, y, width, height);
    
    x = CGRectGetMinX(bounds);
    y = MAX(CGRectGetMaxY(self.newsImageView.frame) + imageInsets.bottom, CGRectGetMaxY(self.newsAuthorLabel.frame));
    width = CGRectGetWidth(bounds);
    height = [self.newsDescLabel heightForWidth:width];
    self.newsDescLabel.frame = CGRectMake(x, y, width, height);
}

@end
