//
//  ADNetworkManager.h
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DataComplitionHandler)( NSDictionary * _Nullable data);
typedef void(^DownloadComplitionHandler)(NSURL * _Nullable location);

typedef NS_ENUM(NSUInteger, ADRequestType) {
    ADRequestTypeTopHeadlines,
    ADRequestTypeEverything,
    ADRequestTypeSource,
};

extern NSString * const ADOptionCountry;
extern NSString * const ADOptionCategory;
extern NSString * const ADOptionSources;
extern NSString * const ADOptionPageSize;
extern NSString * const ADOptionPage;
extern NSString * const ADOptionKeywords;
extern NSString * const ADOptionDomains;
extern NSString * const ADOptionDateFrom;
extern NSString * const ADOptionDateTo;
extern NSString * const ADOptionLanguage;
extern NSString * const ADOptionSortBy;


@interface ADNetworkManager : NSObject

+ (ADNetworkManager *)shared;

- (void)getObjectsForType:(ADRequestType)newsType options:(NSDictionary *)options complitionHandler:(DataComplitionHandler)complitionHandler;
- (void)getDocumentFor:(NSURL *)url withComplitionHandler:(DownloadComplitionHandler)complitionHandler;
@end
