//
//  TableViewCell.m
//  HeadlinesTest
//
//  Created by Ray Vo on 24/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import "BasicCell.h"
#import "Article.h"

@implementation BasicCell

- (void)dealloc
{
    self.titleLabel = nil;
    self.descriptionLabel = nil;
    [super dealloc];
}

@end
