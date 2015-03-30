//
//  DetailsViewController.h
//  HeadlinesTest
//
//  Created by Ray Vo on 30/3/15.
//  Copyright (c) 2015 Truong Vo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Article;

@interface DetailsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) Article *selectedArticle;

@end
