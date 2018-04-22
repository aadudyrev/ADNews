//
//  NSManagedObject+Extension.m
//  ADNews
//
//  Created by Александр Дудырев on 22.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "NSManagedObject+Extension.h"

@implementation NSManagedObject (Extension)

+ (NSDictionary *)allObjectsForEntityName:(NSString *)entityName key:(NSString *)key context:(NSManagedObjectContext *)context {
    if (!key) {
        return @{};
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:objects.count];
    for (NSManagedObject *object in objects) {
        [mDict setObject:object forKey:[object valueForKey:key]];
    }
    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

+ (void)insertObjectsFrom:(NSArray<NSDictionary *> *)sourcesArr inContext:(NSManagedObjectContext *)context {
    NSAssert(NO, @"Метод должен быть перегружен");
}

@end
