//
//  Article.m
//  HeadlinesTest
//
//  Created by Ray Vo on 24/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import "Article.h"

@implementation Article

- (void)dealloc
{
    [_articleTitle release];
    [_articleDescription release];
    [_imageHref release];
    [super dealloc];
}

@end
