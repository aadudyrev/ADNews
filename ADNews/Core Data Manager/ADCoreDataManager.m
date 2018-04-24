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
            // ставим параметр, если нечего нет
            options = options ? options : @{ADOptionCountry : @"ru"};
            break;
        case DBNewsTypeEverything:
            requestType = ADRequestTypeEverything;
            // такой запрос не будем отправлять
            if (!options || !options.count) {
                return;
            }
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
            [self showMessage:@"Некорректный запрос" withTitle:@"Ошибка"];
            return;
        }
        // парсим json
        [DBNews insertObjectsFrom:news type:newsType inContext:weakSelf.mainContext];
    } errorHandler:^(NSError * _Nullable error) {
        [self showMessage:error.localizedDescription withTitle:@"Ошибка"];
    }];
    
}

- (void)downloadSourcesWithOptions:(NSDictionary *)options {
    options = options ? options : @{ADOptionCountry : @"ru"};
    ADNetworkManager *networkManager = [ADNetworkManager shared];
    __weak ADCoreDataManager *weakSelf = self;
    [networkManager getObjectsForType:ADRequestTypeSource options:options complitionHandler:^(NSDictionary * _Nullable data) {
        if (!data || data.count == 0) {
            return;
        }
        NSArray *sources = data[@"sources"];
        if (!sources || sources.count == 0) {
            [self showMessage:@"Некорректный запрос" withTitle:@"Ошибка"];
            return;
        }
        // парсим json
        [DBSource insertObjectsFrom:sources type:0 inContext:weakSelf.mainContext];
    } errorHandler:^(NSError * _Nullable error) {
        [self showMessage:error.localizedDescription withTitle:@"Ошибка"];
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


- (void)deleteAllObjectsForEntityName:(NSString *)name {
    if (!name) {
        return;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    NSArray *objects = [[[ADCoreDataManager shared] mainContext] executeFetchRequest:request error:nil];
    for (DBNews *news in objects) {
        [[[ADCoreDataManager shared] mainContext] deleteObject:news];
    }
    NSError *error;
    if (![[[ADCoreDataManager shared] mainContext] save:&error]) {
        NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
    }
    
}

- (void)showMessage:(NSString *)message withTitle:(NSString *)title {
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [vc presentViewController:alertController animated:YES completion:^{
            
        }];
    });
}

@end
