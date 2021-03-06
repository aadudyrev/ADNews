//
//  DBDocument+CoreDataClass.h
//  ADNews
//
//  Created by Александр Дудырев on 22.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



NS_ASSUME_NONNULL_BEGIN

// статусы загрузки
typedef NS_ENUM(NSUInteger, DBDocumentStatus) {
    DBDocumentStatusNotDownloaded,
    DBDocumentStatusInDownloadProcess,
    DBDocumentStatusDownloaded,
};

@class DBNews;

@interface DBDocument : NSManagedObject

@property (nonatomic, strong) UIImage *newsImage;

// хеш от url
- (NSString *)fileName;

@end

NS_ASSUME_NONNULL_END

#import "DBDocument+CoreDataProperties.h"
