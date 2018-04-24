//
//  DBDocument+CoreDataClass.m
//  ADNews
//
//  Created by Александр Дудырев on 22.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//
//

#import "DBDocument.h"

@implementation DBDocument

@synthesize newsImage = _newsImage;
- (UIImage *)newsImage {
    if (!_newsImage) {
        UIImage *defaultImage = [UIImage imageNamed:@"def-icon-news"];
        switch (self.status) {
            case DBDocumentStatusNotDownloaded: {
                [[ADCoreDataManager shared] downloadDocument:self];
                self.status = DBDocumentStatusInDownloadProcess;
            }
                return defaultImage;
            case DBDocumentStatusInDownloadProcess:
                return defaultImage;
            case DBDocumentStatusDownloaded: {
                NSString *path = self.path ? [[NSFileManager imageDirectory] URLByAppendingPathComponent:self.path].path : nil;
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                _newsImage = image ? image : defaultImage;
            }
                break;
            default:
                break;
        }
    }
    return _newsImage;
}

- (NSString *)fileName {
    NSString *urlHash = [self.url MD5String];
    NSString *extension = [self.url pathExtension];
    return [urlHash stringByAppendingPathExtension:extension];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    // обновляем новость при изменении статуса
    if ([key isEqualToString:@"status"]) {
        [self.news willChangeValueForKey:@"image"];
        [self.news didChangeValueForKey:@"image"];
    }
}

- (void)prepareForDeletion {
    // удаляем документ при удалении новости (каскад)
    if (self.path) {
        NSString *path = [[NSFileManager imageDirectory] URLByAppendingPathComponent:self.path].path;
        [NSFileManager removeItemAtPath:path];
    }
}

@end
