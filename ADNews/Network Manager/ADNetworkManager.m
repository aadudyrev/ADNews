//
//  ADNetworkManager.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "ADNetworkManager.h"

static NSString *defaultURLString = @"https://newsapi.org/v2/";
static NSString *apiKey = @"a5a34baa13db4a0da95e74cc73d6a1f9";

NSString * const ADOptionCountry    = @"country";
NSString * const ADOptionCategory   = @"category";
NSString * const ADOptionSources    = @"sources";
NSString * const ADOptionPageSize   = @"pageSize";
NSString * const ADOptionPage       = @"page";
NSString * const ADOptionKeywords   = @"q";
NSString * const ADOptionDomains    = @"domains";
NSString * const ADOptionDateFrom   = @"from";
NSString * const ADOptionDateTo     = @"to";
NSString * const ADOptionLanguage   = @"language";
NSString * const ADOptionSortBy     = @"sortBy";

@interface ADNetworkManager () <NSURLSessionDelegate>

@end

@implementation ADNetworkManager

+ (ADNetworkManager *)shared {
    static dispatch_once_t onceToken;
    static ADNetworkManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[ADNetworkManager alloc] init];
        [manager configuration];
    });
    return manager;
}

- (void)configuration {
    
}

- (void)getObjectsForType:(ADRequestType)newsType
                  options:(NSDictionary *)options
        complitionHandler:(DataComplitionHandler)complitionHandler
             errorHandler:(DataErrorHandler)errorHandler{
    NSString *endPoint;
    switch (newsType) {
        case ADRequestTypeTopHeadlines:
            endPoint = @"top-headlines?";
            break;
        case ADRequestTypeEverything:
            endPoint = @"everything?";
            break;
        case ADRequestTypeSource:
            endPoint = @"sources?";
            break;
        default:
            break;
    }
    NSURLRequest *request = [self requestWithEndpoints:endPoint options:options];
    NSURLSessionTask *task = [self dataTaskWithRequest:request withComplitionHandler:complitionHandler andErrorHandler:errorHandler];
    [task resume];
}

- (void)getDocumentFor:(NSURL *)url
 withComplitionHandler:(DownloadComplitionHandler)complitionHandler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSURLSessionTask *downloadTask = [self downloadTaskWithRequest:request withComplitionHandler:complitionHandler];
    [downloadTask resume];
}

- (NSURLRequest *)requestWithEndpoints:(NSString *)endPoint options:(NSDictionary *)options {
    NSString *urlString = [self stringWithEndPoint:endPoint andOptions:options];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    // apikey ставим в заголовки
    [request setValue:apiKey forHTTPHeaderField:@"X-Api-Key"];
    return request;
}

- (NSURLSessionTask *)dataTaskWithRequest:(NSURLRequest *)request withComplitionHandler:(DataComplitionHandler)complitionHandler andErrorHandler:(DataErrorHandler)errorHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
            if (errorHandler) {
                errorHandler(error);
            }
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
            case 200:
                break;
            case 401: {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey : @"Ошибка авторизации",
                                           };
                error = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:userInfo];
            }
            default: {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey : @"Ошибка при выполнении запроса",
                                           };
                error = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:userInfo];
            }
        }
        if (error != nil) {
            NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
            if (errorHandler) {
                errorHandler(error);
            }
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error != nil) {
            NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : @"Ошибка при обработке данных",
                                       };
            error = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:userInfo];
            if (errorHandler) {
                errorHandler(error);
            }
            return;
        }
        if (complitionHandler) {
            complitionHandler(json);
        }
    }];
    NSLog(@"request to URL: %@", request.URL.absoluteString);
    return dataTask;
}

- (NSURLSessionTask *)downloadTaskWithRequest:(NSURLRequest *)request
                        withComplitionHandler:(DownloadComplitionHandler)complitionHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
            return;
        }
        if (complitionHandler) {
            complitionHandler(location);
        }
    }];
    return downloadTask;
}

- (NSString *)stringWithEndPoint:(NSString *)endPoint andOptions:(NSDictionary *)options {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", defaultURLString, endPoint];
    NSMutableString *mOptionsStr = [[NSMutableString alloc] init];
    NSInteger count = options.count;
    for (NSInteger i = 0; i < count; i++) {
        NSString *key = options.allKeys[i];
        NSString *tmpStr = [NSString stringWithFormat:@"%@=%@", key, options[key]];
        if (i < count - 1) {
            [tmpStr stringByAppendingString:@"&"];
        }
        [mOptionsStr appendString:tmpStr];
    }
    // для кириллицы
    NSCharacterSet *pathCharSet = [NSCharacterSet URLPathAllowedCharacterSet];
    NSString *optionsStr = [mOptionsStr stringByAddingPercentEncodingWithAllowedCharacters:pathCharSet];
    return [urlString stringByAppendingString:optionsStr];
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}







@end
