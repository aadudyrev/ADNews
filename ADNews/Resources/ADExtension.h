//
//  ADExtension.h
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


CGFloat heightForInsets(UIEdgeInsets insets);
CGFloat widthForInsets(UIEdgeInsets insets);


@interface NSDateFormatter (Ext)

+ (NSDateFormatter *)longDf;

@end

@interface NSString (Ext)

- (NSString *)MD5String;
+ (NSString *)generateStringWithLenght:(NSInteger)lenght;

@end

@interface NSFileManager (Ext)
// директория пользователя
+ (NSURL *)userDirectory;
// директория для изображений (документов)
+ (NSURL *)imageDirectory;
// удаляем файл 
+ (void)removeItemAtPath:(NSString *)path;

@end
