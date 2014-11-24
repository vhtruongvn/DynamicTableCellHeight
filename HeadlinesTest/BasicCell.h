//
//  TableViewCell.h
//  HeadlinesTest
//
//  Created by Ray Vo on 24/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Article;

@interface BasicCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@end
