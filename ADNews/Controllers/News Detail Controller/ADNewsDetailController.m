//
//  ADNewsDetailController.m
//  ADNews
//
//  Created by Александр Дудырев on 22.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "ADNewsDetailController.h"

@interface ADNewsDetailController ()

@property (nonatomic, strong) DBNews *news;

@property (nonatomic, strong) UIImageView *newsImageView;
@property (nonatomic, strong) ADLabel *newsTitleLabel;
@property (nonatomic, strong) ADLabel *newsAuthorLabel;
@property (nonatomic, strong) ADLabel *newsDescLabel;
@property (nonatomic, strong) ADLabel *sourceNameLabel;
@property (nonatomic, strong) ADLabel *newsPublishedDateLabel;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *urlButton;

@end

@implementation ADNewsDetailController

- (instancetype)initWithNews:(DBNews *)news
{
    self = [super init];
    if (self) {
        self.news = news;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"News!";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // подпишемся на изменение контекста
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.news.managedObjectContext];
    
    [self configure];
    [self configureWithNews:self.news];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    bounds.size.height -= CGRectGetHeight(self.tabBarController.tabBar.frame);
    CGFloat imageHeight = 200;
    CGFloat buttonHeight = 40;
    
    CGSize contentSize = CGSizeMake(CGRectGetWidth(bounds), 0);
    CGFloat titleHeight = [self.newsTitleLabel heightForWidth:contentSize.width];
    CGFloat authorHeight = [self.newsAuthorLabel heightForWidth:contentSize.width];
    CGFloat descrHeight = [self.newsDescLabel heightForWidth:contentSize.width];
    CGFloat sourceNameHeight = [self.sourceNameLabel heightForWidth:contentSize.width];
    CGFloat publishedDateHeight = [self.newsPublishedDateLabel heightForWidth:contentSize.width];
    
    CGFloat x = CGRectGetMinX(bounds);
    CGFloat width = CGRectGetWidth(bounds);
    
    contentSize.height = imageHeight + titleHeight + authorHeight + descrHeight + sourceNameHeight + publishedDateHeight;
    self.scrollView.contentSize = contentSize;
    
    self.scrollView.frame = CGRectMake(x, CGRectGetMinY(bounds), CGRectGetWidth(bounds), CGRectGetHeight(bounds) - buttonHeight);
    self.urlButton.frame = CGRectMake(x, CGRectGetMaxY(self.scrollView.frame), width, buttonHeight);
    
    x = self.scrollView.contentOffset.x;
    width = self.scrollView.contentSize.width;
    
    self.newsImageView.frame = CGRectMake(x, 0, width, imageHeight);
    self.newsTitleLabel.frame = CGRectMake(x, CGRectGetMaxY(self.newsImageView.frame), width, titleHeight);
    self.newsAuthorLabel.frame = CGRectMake(x, CGRectGetMaxY(self.newsTitleLabel.frame), width, authorHeight);
    self.newsDescLabel.frame = CGRectMake(x, CGRectGetMaxY(self.newsAuthorLabel.frame ), width, descrHeight);
    self.sourceNameLabel.frame = CGRectMake(x, CGRectGetMaxY(self.newsDescLabel.frame), width, sourceNameHeight);
    self.newsPublishedDateLabel.frame = CGRectMake(x, CGRectGetMaxY(self.sourceNameLabel.frame), width, publishedDateHeight);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // отпишемся от нотификаций
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:self.news];
}

- (void)configure {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    self.newsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.newsImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.newsImageView];
    
    self.newsTitleLabel = [[ADLabel alloc] initWithFrame:CGRectZero];
    self.newsTitleLabel.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.newsTitleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    self.newsTitleLabel.textColor = [UIColor blackColor];
    [self.scrollView addSubview:self.newsTitleLabel];
    
    self.newsAuthorLabel = [[ADLabel alloc] initWithFrame:CGRectZero];
    self.newsAuthorLabel.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.newsAuthorLabel.font = [UIFont italicSystemFontOfSize:12.f];
    self.newsAuthorLabel.textColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:self.newsAuthorLabel];
    
    self.newsDescLabel = [[ADLabel alloc] initWithFrame:CGRectZero];
    self.newsDescLabel.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.newsDescLabel.font = [UIFont systemFontOfSize:15.f];
    self.newsDescLabel.textColor = [UIColor blackColor];
    [self.scrollView addSubview:self.newsDescLabel];
    
    self.sourceNameLabel = [[ADLabel alloc] initWithFrame:CGRectZero];
    self.sourceNameLabel.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.scrollView addSubview:self.sourceNameLabel];
    
    self.newsPublishedDateLabel = [[ADLabel alloc] initWithFrame:CGRectZero];
    self.newsPublishedDateLabel.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.scrollView addSubview:self.newsPublishedDateLabel];
    
    NSString *buttonStr = @"Go to news";
    NSDictionary *atrb = @{
                           NSFontAttributeName : [UIFont italicSystemFontOfSize:16.f],
                           NSForegroundColorAttributeName : [UIColor blueColor],
                           };
    NSAttributedString *normalStateStr = [[NSAttributedString alloc] initWithString:buttonStr
                                                                         attributes:atrb];
    self.urlButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.urlButton addTarget:self action:@selector(urlButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self.urlButton setAttributedTitle:normalStateStr forState:UIControlStateNormal];
    [self.view addSubview:self.urlButton];
}

- (void)configureWithNews:(DBNews *)news {
    self.newsTitleLabel.text = news.title ? news.title : @"";
    self.newsAuthorLabel.text = news.author ? news.author : @"";
    self.newsDescLabel.text = news.descr ? news.descr : @"";
    
    UIImage *image = [news.image newsImage] ? [news.image newsImage] : [UIImage imageNamed:@"def-icon-news"];
    self.newsImageView.image = image;
    
    NSMutableParagraphStyle *mParagraph = [[NSMutableParagraphStyle alloc] init];
    [mParagraph setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    mParagraph.lineBreakMode = NSLineBreakByTruncatingTail;
    mParagraph.alignment = NSTextAlignmentLeft;
    
    if (self.news.publishedAt) {
        NSDateFormatter *df = [NSDateFormatter longDf];
        NSString *dateStr = [df stringFromDate:self.news.publishedAt];
        NSMutableAttributedString *mAtrbStr = [[NSMutableAttributedString alloc] init];
        NSAttributedString *dateAtrbStr;
        dateAtrbStr = [[NSAttributedString alloc] initWithString:@"Дата Публикации\n"
                                                      attributes:@{
                                                                   NSFontAttributeName : [UIFont systemFontOfSize:12.f],
                                                                   NSForegroundColorAttributeName : [UIColor blackColor],
                                                                   NSParagraphStyleAttributeName : mParagraph,
                                                                   }];
        [mAtrbStr appendAttributedString:dateAtrbStr];
        dateAtrbStr = [[NSAttributedString alloc] initWithString:dateStr
                                                      attributes:@{
                                                                   NSFontAttributeName : [UIFont italicSystemFontOfSize:10.f],
                                                                   NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                                                   NSParagraphStyleAttributeName : mParagraph,
                                                                   }];
        [mAtrbStr appendAttributedString:dateAtrbStr];
        self.newsPublishedDateLabel.attributedText = mAtrbStr;
    }
    if (self.news.source.name) {
        NSString *sourceName = self.news.source.name;
        NSMutableAttributedString *mAtrbStr = [[NSMutableAttributedString alloc] init];
        NSAttributedString *dateAtrbStr;
        dateAtrbStr = [[NSAttributedString alloc] initWithString:@"Источник\n"
                                                      attributes:@{
                                                                   NSFontAttributeName : [UIFont systemFontOfSize:13.f],
                                                                   NSForegroundColorAttributeName : [UIColor blackColor],
                                                                   NSParagraphStyleAttributeName : mParagraph,
                                                                   }];
        [mAtrbStr appendAttributedString:dateAtrbStr];
        dateAtrbStr = [[NSAttributedString alloc] initWithString:sourceName
                                                      attributes:@{
                                                                   NSFontAttributeName : [UIFont italicSystemFontOfSize:11.f],
                                                                   NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                                                   NSParagraphStyleAttributeName : mParagraph,
                                                                   }];
        [mAtrbStr appendAttributedString:dateAtrbStr];
        self.sourceNameLabel.attributedText = mAtrbStr;
    }
}

#pragma mark - Notification

- (void)reloadData:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSSet *updated = userInfo[NSUpdatedObjectsKey];
    NSSet *deleted = userInfo[NSDeletedObjectsKey];
    if ([updated containsObject:self.news]) {
        [self configureWithNews:self.news];
        [self.view setNeedsLayout];
    }
    if ([deleted containsObject:self.news]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Actions

- (void)urlButtonTaped:(UIButton *)button {
    if (![self.news url]) {
        return;
    }
    NSURL *url = [NSURL URLWithString:self.news.url];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
}

@end
