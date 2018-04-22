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

- (NSString *)fileName {
    NSString *urlHash = [self.url MD5String];
    NSString *extension = [self.url pathExtension];
    return [urlHash stringByAppendingPathExtension:extension];
}

- (UIImage *)getImage {
    UIImage *defImage = [UIImage imageNamed:@"def-icon-news"];
    if (!self.url) {
        return defImage;
    }
    switch (self.status) {
        case DBDocumentStatusNotDownloaded: {
            [[ADCoreDataManager shared] downloadDocument:self];
            self.status = DBDocumentStatusInDownloadProcess;
        }
        case DBDocumentStatusInDownloadProcess:
            break;
        case DBDocumentStatusDownloaded: {
            NSString *path = self.path ? [[NSFileManager imageDirectory] URLByAppendingPathComponent:self.path].path : nil;
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            return image ? image : defImage;
        }
        default:
            break;
    }
    return defImage;
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    if ([key isEqualToString:@"status"] || [key isEqualToString:@"path"]) {
        [self.news willChangeValueForKey:@"image"];
        [self.news didChangeValueForKey:@"image"];
    }
}

- (void)prepareForDeletion {
    if (self.path) {
        NSString *path = [[NSFileManager imageDirectory] URLByAppendingPathComponent:self.path].path;
        [NSFileManager removeItemAtPath:path];
    }
}

@end
