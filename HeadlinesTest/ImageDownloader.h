//
//  ImageDownloader.h
//  HeadlinesTest
//
//  Created by Ray Vo on 25/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Article;

@interface ImageDownloader : NSObject

@property (nonatomic, retain) Article *article;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@end
