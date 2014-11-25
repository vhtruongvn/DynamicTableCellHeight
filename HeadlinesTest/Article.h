//
//  Article.h
//  HeadlinesTest
//
//  Created by Ray Vo on 24/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (nonatomic, retain) NSString *articleTitle;
@property (nonatomic, retain) NSString *articleDescription;
@property (nonatomic, retain) NSString *imageHref;
@property (nonatomic, retain) UIImage *articlePhoto;
@property (nonatomic, assign) BOOL hasPhoto;

@end
