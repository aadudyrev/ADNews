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




@interface NSString (Generator)

- (NSString *)MD5String;
+ (NSString *)generateStringWithLenght:(NSInteger)lenght;

@end

@interface NSFileManager (Extension)

+ (NSURL *)userDirectory;
+ (NSURL *)imageDirectory;
+ (void)removeItemAtPath:(NSString *)path;

@end
