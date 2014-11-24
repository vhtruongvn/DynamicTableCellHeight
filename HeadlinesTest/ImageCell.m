//
//  TableViewImageCell.m
//  HeadlinesTest
//
//  Created by Ray Vo on 24/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell

@synthesize photoView;

- (void)dealloc
{
    self.photoView = nil;
    [super dealloc];
}
@end
