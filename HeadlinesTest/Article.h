//
//  Article.h
//  HeadlinesTest
//
//  Created by Ray Vo on 24/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (retain) NSString *articleTitle;
@property (retain) NSString *articleDescription;
@property (retain) NSString *imageHref;
@property (assign) BOOL hasPhoto;

@end
