//
//  ADCoreDataManager.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "ADCoreDataManager.h"

@interface ADCoreDataManager ()

@property (nonatomic, strong) NSPersistentContainer *persistentContainer;

@end

@implementation ADCoreDataManager

+ (ADCoreDataManager *)shared {
    static dispatch_once_t onceToken;
    static ADCoreDataManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[ADCoreDataManager alloc] init];
        [manager configuration];
    });
    
    return manager;
}

- (void)configuration {
    [self persistentContainer];
}

- (NSManagedObjectContext *)mainContext {
    return self.persistentContainer.viewContext;
}

- (NSPersistentContainer *)persistentContainer {
    if (_persistentContainer) {
        return _persistentContainer;
    }
    @synchronized (self) {
        _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"ADNews"];
        [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }];
    }
    
    return _persistentContainer;
}


- (void)downloadNewsForType:(DBNewsType)newsType withOptions:(NSDictionary *)options {
    ADRequestType requestType;
    switch (newsType) {
        case DBNewsTypeTopHeadlines:
            requestType = ADRequestTypeTopHeadlines;
            break;
        case DBNewsTypeEverything:
            requestType = ADRequestTypeEverything;
            break;
        default:
            return;
            break;
    }
    __weak ADCoreDataManager *weakSelf = self;
    [[ADNetworkManager shared] getObjectsForType:requestType options:options complitionHandler:^(NSDictionary * _Nullable data) {
        if (!data || data.count == 0) {
            return;
        }
        NSArray *news = data[@"articles"];
        if (!news || news.count == 0) {
            return;
        }
        [DBNews insertObjectsFrom:news inContext:weakSelf.persistentContainer.viewContext];
    }];
}

- (void)downloadSourcesWithOptions:(NSDictionary *)options {
    ADNetworkManager *networkManager = [ADNetworkManager shared];
    __weak ADCoreDataManager *weakSelf = self;
    [networkManager getObjectsForType:ADRequestTypeSource options:options complitionHandler:^(NSDictionary * _Nullable data) {
        if (!data || data.count == 0) {
            return;
        }
        NSArray *sources = data[@"sources"];
        if (!sources || sources.count == 0) {
            return;
        }        
        [DBSource insertObjectsFrom:sources inContext:weakSelf.persistentContainer.viewContext];
    }];
}

- (void)downloadDocument:(NSManagedObject *)object {
    if (![object isKindOfClass:[DBDocument class]]) {
        return;
    }
    DBDocument *document = (DBDocument *)object;
    NSURL *url = [NSURL URLWithString:document.url];
    if (!url) {
        return;
    }
    
    ADNetworkManager *networkManager = [ADNetworkManager shared];
    __weak ADCoreDataManager *weakSelf = self;
    [networkManager getDocumentFor:url withComplitionHandler:^(NSURL * _Nullable location) {
        [weakSelf.mainContext performBlockAndWait:^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *imageDir = [NSFileManager imageDirectory];
            NSString *fileName = [document fileName];
            imageDir = [imageDir URLByAppendingPathComponent:fileName];
            NSError *error;
            if (![fileManager fileExistsAtPath:imageDir.path]) {
                if ([fileManager copyItemAtURL:location toURL:imageDir error:&error]) {
                    NSError *error;
                    if (error != nil) {
                        NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
                        return;
                    }
                    [NSFileManager removeItemAtPath:location.path];
                } else {
                    if (error != nil) {
                        NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
                        abort();
                    }
                }
            }
            document.path = [imageDir lastPathComponent];
            document.status = DBDocumentStatusDownloaded;
            if (document.hasChanges) {
                NSError *error;
                if ([weakSelf.mainContext hasChanges] && ![weakSelf.mainContext save:&error]) {
                    NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
                    abort();
                }
            }
        }];
    }];
}

@end
