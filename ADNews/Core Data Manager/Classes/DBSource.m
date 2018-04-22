//
//  DBSource+CoreDataClass.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//
//

#import "DBSource.h"

@implementation DBSource

@synthesize sourceKey = _sourceKey;
- (NSString *)sourceKey {
    if (!_sourceKey) {
        _sourceKey = [NSString stringWithFormat:@"%@%@", self.sourcesId, self.name];
    }
    return _sourceKey;
}

+ (void)insertObjectsFrom:(NSArray <NSDictionary *> *)sourcesArr inContext:(NSManagedObjectContext *)context {
    NSString *className = NSStringFromClass([DBSource class]);
    NSString *key = @"url";
    NSDictionary *sourcesData = [self allObjectsForEntityName:className key:key context:context];
    
    [context performBlockAndWait:^{
        for (NSDictionary *dict in sourcesArr) {
            NSString *url = dict[key];
            DBSource *source = sourcesData[url];
            if (!source) {
                source = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
            }
            source.sourcesId    = [dict[@"id"] isKindOfClass:[NSNull class]] ? nil : dict[@"id"];
            source.name         = [dict[@"name"] isKindOfClass:[NSNull class]] ? nil : dict[@"name"];
            source.descr        = [dict[@"description"] isKindOfClass:[NSNull class]] ? nil : dict[@"description"];
            source.url          = [dict[@"url"] isKindOfClass:[NSNull class]] ? nil : dict[@"url"];
            source.category     = [dict[@"category"] isKindOfClass:[NSNull class]] ? nil : dict[@"category"];
            source.language     = [dict[@"language"] isKindOfClass:[NSNull class]] ? nil : dict[@"language"];
            source.country      = [dict[@"country"] isKindOfClass:[NSNull class]] ? nil : dict[@"country"];
        }
        
        NSError *error;
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
            abort();
        }
    }];

}

@end
