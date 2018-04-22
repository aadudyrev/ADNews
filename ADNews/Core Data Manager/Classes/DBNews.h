//
//  DBNews+CoreDataClass.h
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class DBSource, DBDocument;

@interface DBNews : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "DBNews+CoreDataProperties.h"
