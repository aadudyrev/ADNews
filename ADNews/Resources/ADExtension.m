//
//  ADExtension.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "ADExtension.h"
#import <CommonCrypto/CommonDigest.h>

CGFloat heightForInsets(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

CGFloat widthForInsets(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

@implementation NSDateFormatter (Ext)

+ (NSDateFormatter *)longDf {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterLongStyle;
    df.dateFormat = @"E, d MMM yyyy HH:mm:ss";
    return df;
}

@end

@implementation NSString (Ext)

- (NSString *)MD5String {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)generateStringWithLenght:(NSInteger)lenght {
    static NSString *characters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ";
    
    if (!lenght) {
        lenght = arc4random() % 240;
    }
    
    NSMutableString *mString = [[NSMutableString alloc] initWithCapacity:lenght];
    for (NSInteger i = 0; i < lenght; i++) {
        NSInteger random = arc4random() % characters.length;
        NSRange range = NSMakeRange(random, 1);
        NSString *oneCharacter = [characters substringWithRange:range];
        [mString appendString:oneCharacter];
    }
    return [NSString stringWithString:mString];
}

@end


@implementation NSFileManager (Ext)

+ (NSURL *)userDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *dirURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return dirURL;
}

+ (NSURL *)imageDirectory {
    NSFileManager *fileManager = [self defaultManager];
    NSURL *imageDir = [[self userDirectory] URLByAppendingPathComponent:@"Images" isDirectory:YES];
    BOOL dir;
    if (![fileManager fileExistsAtPath:imageDir.path isDirectory:&dir]) {
        NSError *error;
        if ([fileManager createDirectoryAtPath:imageDir.path withIntermediateDirectories:NO attributes:nil error:&error]) {
            if (error != nil) {
                NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
                abort();
            }
        }
    }
    if (dir == NO) {
        NSError *error;
        if (![fileManager removeItemAtURL:imageDir error:&error]) {
            if (error != nil) {
                NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
                abort();
            }
        }
        if ([fileManager createDirectoryAtPath:imageDir.path withIntermediateDirectories:NO attributes:nil error:&error]) {
            if (error != nil) {
                NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
                abort();
            }
        }
    }
    return imageDir;
}

+ (void)removeItemAtPath:(NSString *)path {
    if (!path) {
        return;
    }
    NSFileManager *fileManager = [self defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:path]) {
        if (![fileManager removeItemAtPath:path error:&error]) {
            NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
            abort();
        }
    }
}

@end




