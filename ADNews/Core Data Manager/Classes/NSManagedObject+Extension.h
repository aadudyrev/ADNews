//
//  NSManagedObject+Extension.h
//  ADNews
//
//  Created by Александр Дудырев on 22.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Extension)

// парсим json
+ (void)insertObjectsFrom:(NSArray <NSDictionary *> *)sourcesArr type:(NSInteger)type inContext:(NSManagedObjectContext *)context;
// вернем уже сохраненные объекты
+ (NSDictionary *)allObjectsForEntityName:(NSString *)entityName key:(NSString *)key context:(NSManagedObjectContext *)context;

@end
