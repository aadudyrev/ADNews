//
//  DBNews+CoreDataClass.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//
//

#import "DBNews.h"

@implementation DBNews

+ (void)insertObjectsFrom:(NSArray <NSDictionary *> *)newsArr type:(NSInteger)newsType inContext:(NSManagedObjectContext *)context {
    NSString *newsClassName = NSStringFromClass([DBNews class]);
    NSString *sourceClassName = NSStringFromClass([DBSource class]);
    NSString *documentClassName = NSStringFromClass([DBDocument class]);
    NSISO8601DateFormatter *df = [[NSISO8601DateFormatter alloc] init];
    
    NSString *newskey = @"url";
    NSString *sourceKey = @"name";
    NSDictionary *newsData = [self allObjectsForEntityName:newsClassName key:newskey context:context];
    NSDictionary *currentSourcesData = [self allObjectsForEntityName:sourceClassName key:sourceKey context:context];
    NSMutableDictionary *sourcesData = [NSMutableDictionary dictionaryWithDictionary:currentSourcesData];
    
    [context performBlockAndWait:^{
        for (NSDictionary *dict in newsArr) {
            NSString *url = dict[newskey];
            DBNews *news = newsData[url];
            if (news != nil) {
                continue;
            }
            news = [NSEntityDescription insertNewObjectForEntityForName:newsClassName inManagedObjectContext:context];
            news.author         = [dict[@"author"] isKindOfClass:[NSNull class]] ? nil : dict[@"author"];
            news.title          = [dict[@"title"] isKindOfClass:[NSNull class]] ? nil : dict[@"title"];
            news.descr          = [dict[@"description"] isKindOfClass:[NSNull class]] ? nil : dict[@"description"];
            news.url            = [dict[@"url"] isKindOfClass:[NSNull class]] ? nil : dict[@"url"];
            news.publishedAt    = [df dateFromString:dict[@"publishedAt"]];
            news.type           = newsType;
            news.textForSearch   = [NSString stringWithFormat:@"%@ %@ %@", news.author, news.title, news.descr];
            
            NSDictionary *sourceDict = dict[@"source"];
            NSString *sourceId = [sourceDict[@"id"] isKindOfClass:[NSNull class]] ? nil : sourceDict[@"id"];
            NSString *sourceName = [sourceDict[@"name"] isKindOfClass:[NSNull class]] ? nil : sourceDict[@"name"];
            if (sourceName && sourceName.length > 0) {
                DBSource *source = sourcesData[sourceName];
                if (!source) {
                    source = [NSEntityDescription insertNewObjectForEntityForName:sourceClassName inManagedObjectContext:context];
                    source.name = sourceName;
                    source.sourcesId = sourceId;
                    
                    sourcesData[sourceName] = source;
                }
                [source addNewsObject:news];
                news.source = source;
            }
            
            DBDocument *document = [NSEntityDescription insertNewObjectForEntityForName:documentClassName inManagedObjectContext:context];
            document.url = [dict[@"urlToImage"] isKindOfClass:[NSNull class]] ? nil : dict[@"urlToImage"];
            document.status = DBDocumentStatusNotDownloaded;
            news.image = document;
            document.news = news;
        }
        NSError *error;
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
            abort();
        }
    }];
    
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
}

@end
