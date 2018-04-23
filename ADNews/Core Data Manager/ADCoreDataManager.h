//
//  ADCoreDataManager.h
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, DBNewsType) {
    DBNewsTypeTopHeadlines,
    DBNewsTypeEverything,
};

@interface ADCoreDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *mainContext;

+ (ADCoreDataManager *)shared;

// загружаем новости
- (void)downloadNewsForType:(DBNewsType)newsType withOptions:(NSDictionary *)options;
// загружаем источники
- (void)downloadSourcesWithOptions:(NSDictionary *)options;
// загружаем документы
- (void)downloadDocument:(NSManagedObject *)object;

// удаляем объекты
- (void)deleteAllObjectsForEntityName:(NSString *)name;

@end
