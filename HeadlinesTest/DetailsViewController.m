//
//  DetailsViewController.m
//  HeadlinesTest
//
//  Created by Ray Vo on 30/3/15.
//  Copyright (c) 2015 Truong Vo. All rights reserved.
//

#import "DetailsViewController.h"
#import "Article.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Details";
    
    if (self.selectedArticle) {
        NSString *title = [_selectedArticle.articleTitle isKindOfClass:[NSString class]] ? _selectedArticle.articleTitle : @"No Title";
        NSString *description = [_selectedArticle.articleDescription isKindOfClass:[NSString class]] ? _selectedArticle.articleDescription : @"No Description";
        
        self.titleLabel.text = title;
        self.descriptionLabel.text = description;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.selectedArticle = nil;
    self.titleLabel = nil;
    self.descriptionLabel = nil;
    
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
