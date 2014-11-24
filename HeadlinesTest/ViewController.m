//
//  ViewController.m
//  HeadlinesTest
//
//  Created by Ray Vo on 24/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import "ViewController.h"
#import "Article.h"
#import "BasicCell.h"
#import "ImageCell.h"

static NSString * const kBasicCellIdentifier = @"BasicCell";
static NSString * const kImageCellIdentifier = @"ImageCell";

@interface ViewController ()
{
    NSMutableArray *_articles;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Welcome";
    
    self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:142/255.0f green:68/255.0f blue:173/255.0f alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(downloadData) forControlEvents:UIControlEventValueChanged];
    
    _articles = [[NSMutableArray alloc] init];
    
    [self downloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.refreshControl = nil;
    [_articles release];
    [super dealloc];
}

#pragma mark - Button Tap Handlers

- (void)errorButtonTapped:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Unable to refresh. Please pull down to try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *article = _articles[indexPath.row];
    if (article.hasPhoto)
    {
        return [self imageCellAtIndexPath:indexPath];
    }
    else
    {
        return [self basicCellAtIndexPath:indexPath];
    }
}

- (BasicCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath
{
    BasicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kBasicCellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self configureBasicCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureBasicCell:(BasicCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Article *article = _articles[indexPath.row];
    NSString *title = [NSString stringWithFormat:@"%@", article.articleTitle];
    NSString *description = [NSString stringWithFormat:@"%@", article.articleDescription];
    
    cell.titleLabel.text = title;
    cell.descriptionLabel.text = description;
}

- (ImageCell *)imageCellAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kImageCellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self configureImageCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureImageCell:(ImageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Article *article = _articles[indexPath.row];
    NSString *title = [NSString stringWithFormat:@"%@", article.articleTitle];
    NSString *description = [NSString stringWithFormat:@"%@", article.articleDescription];
    
    cell.titleLabel.text = title;
    cell.descriptionLabel.text = description;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *article = _articles[indexPath.row];
    if (article.hasPhoto)
    {
        return [self heightForImageCellAtIndexPath:indexPath];
    }
    else
    {
        return [self heightForBasicCellAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    BasicCell *sizingCell = [self.tableView dequeueReusableCellWithIdentifier:kBasicCellIdentifier];
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)heightForImageCellAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *sizingCell = [self.tableView dequeueReusableCellWithIdentifier:kImageCellIdentifier];;
    [self configureImageCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // User stopped dragging the table view
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // The table view stopped scrolling
}

#pragma mark - Private Methods

- (void)downloadData
{
    NSString *title = [NSString stringWithFormat:@"Updating..."];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
    [attributedTitle release];
    [self.refreshControl beginRefreshing];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSError *downloadError = nil;
        NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/746330/facts.json"];
        NSString *responseString = [NSString stringWithContentsOfURL:url encoding:NSISOLatin1StringEncoding error:&downloadError];
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError = nil;
        NSDictionary *json = nil;
        if (responseData)
        {
            json = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:0
                                                                   error:&jsonError];
        }
        
        // Load data from local file (for Testing only)
        /*NSError *error;
        NSString *responseString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"facts" ofType:@"json"] encoding:NSISOLatin1StringEncoding error:&error];
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:0
                                                               error:&error];*/
        
        if (json == nil)
        {
            NSLog(@"%@", downloadError);
            NSLog(@"%@", jsonError);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *buttonImage = [UIImage imageNamed:@"Error"];
                UIButton *errorButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [errorButton setImage:buttonImage forState:UIControlStateNormal];
                [errorButton setImage:buttonImage forState:UIControlStateHighlighted];
                [errorButton addTarget:self action:@selector(errorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                errorButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
                UIBarButtonItem *settingsBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:errorButton] autorelease];
                self.navigationItem.rightBarButtonItem = settingsBarButtonItem;
            });
        }
        else
        {
            NSLog(@"%@", json);
            
            [_articles removeAllObjects];
            
            if (json)
            {
                if ([json objectForKey:@"title"]
                    && [[json objectForKey:@"title"] isKindOfClass:[NSString class]])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.title = [json objectForKey:@"title"];
                    });
                }
                
                if ([json objectForKey:@"rows"]
                    && [[json objectForKey:@"rows"] isKindOfClass:[NSArray class]])
                {
                    for (NSDictionary *articleData in [json objectForKey:@"rows"])
                    {
                        Article *article = [[Article alloc] init];
                        
                        article.articleTitle = articleData[@"title"];
                        article.articleDescription = articleData[@"description"];
                        article.imageHref = articleData[@"imageHref"];
                        article.hasPhoto = YES; // Assume article has photo and the photo is valid
                        
                        [_articles addObject:article];
                        [article release];
                    }
                }
            }
            
            NSLog(@"%@", _articles);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Reload table data
                [self.tableView reloadData];

                // End refreshing
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MMM d, h:mm a"];
                NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
                NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                self.refreshControl.attributedTitle = attributedTitle;
                [self.refreshControl endRefreshing];
                [attributedTitle release];
                [formatter release];
            });
        }
    });
}

- (BOOL)isLandscapeOrientation
{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

@end
