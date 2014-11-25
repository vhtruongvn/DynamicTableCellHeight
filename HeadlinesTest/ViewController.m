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
#import "ImageDownloader.h"

static NSString *kBasicCellIdentifier = @"BasicCell";
static NSString *kImageCellIdentifier = @"ImageCell";

@interface ViewController ()
{
    NSMutableArray *_articles;
    NSMutableDictionary *_imageDownloadingsList;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Welcome";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:149/255.0f green:165/255.0f blue:166/255.0f alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(downloadData) forControlEvents:UIControlEventValueChanged];
    
    _articles = [[NSMutableArray alloc] init];
    _imageDownloadingsList = [[NSMutableDictionary alloc] init];
    
    [self downloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self terminateAllPhotoDownloads];
}

- (void)dealloc
{
    self.refreshControl = nil;
    [_articles release];
    [self terminateAllPhotoDownloads];
    [_imageDownloadingsList release];
    
    [super dealloc];
}

#pragma mark - Button Tap Handlers

- (void)errorButtonTapped:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Unable to refresh. Please try again."
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
    NSString *title = [NSString stringWithFormat:@"%@", [article.articleTitle isKindOfClass:[NSString class]] ? article.articleTitle : @"No Title"];
    NSString *description = [NSString stringWithFormat:@"%@", [article.articleDescription isKindOfClass:[NSString class]] ? article.articleDescription : @"No Description"];
    
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
    NSString *title = [article.articleTitle isKindOfClass:[NSString class]] ? article.articleTitle : @"No Title";
    NSString *description = [article.articleDescription isKindOfClass:[NSString class]] ? article.articleDescription : @"No Description";
    NSString *photoURLString = [article.imageHref isKindOfClass:[NSString class]] ? article.imageHref : nil;
    
    cell.titleLabel.text = title;
    cell.descriptionLabel.text = description;
    
    if (photoURLString)
    {
        NSLog(@"--- [%@] has photo url", article.articleTitle);
        
        if (article.articlePhoto)
        {
            NSLog(@"--- [%@] load photo from cache", article.articleTitle);
            
            [cell.photoView setImage:article.articlePhoto];
        }
        else
        {
            // Show a placeholder image first
            // Only download photo when:
            // 1. User stopped dragging the table view
            // 2. The table view stopped scrolling
            cell.photoView.image = [UIImage imageNamed:@"Placeholder"];
        }
    }
    else
    {
        NSLog(@"--- [%@] has no photo", article.articleTitle);
        
        article.hasPhoto = NO;
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
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
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // The table view stopped scrolling
    [self loadImagesForOnscreenRows];
}

#pragma mark - Data & Image Download Methods

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
        /*NSError *downloadError;
        NSString *responseString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"facts" ofType:@"json"] encoding:NSISOLatin1StringEncoding error:&downloadError];
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:0
                                                               error:&jsonError];*/
        
        if (json == nil)
        {
            NSLog(@"%@", downloadError);
            NSLog(@"%@", jsonError);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Show error button
                if (downloadError || jsonError)
                {
                    UIImage *buttonImage = [UIImage imageNamed:@"Error"];
                    UIButton *errorButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [errorButton setImage:buttonImage forState:UIControlStateNormal];
                    [errorButton setImage:buttonImage forState:UIControlStateHighlighted];
                    [errorButton addTarget:self action:@selector(errorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    errorButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
                    UIBarButtonItem *settingsBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:errorButton] autorelease];
                    self.navigationItem.rightBarButtonItem = settingsBarButtonItem;
                }
                
                // Display a message when the table is empty
                UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
                messageLabel.text = @"No data is currently available.\nPlease pull down to refresh.";
                messageLabel.textColor = [UIColor colorWithRed:127/255.0f green:140/255.0f blue:141/255.0f alpha:1];
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.font = [UIFont boldSystemFontOfSize:20];
                [messageLabel sizeToFit];
                self.tableView.backgroundView = messageLabel;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [messageLabel release];
            });
        }
        else
        {
            NSLog(@"%@", json);
            
            // Force refreshing
            [self terminateAllPhotoDownloads];
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
                        article.hasPhoto = YES; // this field will be updated after photo is downloaded
                        
                        [_articles addObject:article];
                        
                        [article release];
                    }
                }
            }
            
            NSLog(@"%@", _articles);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Remove error button
                self.navigationItem.rightBarButtonItem = nil;
                
                // Reload table data
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                self.tableView.backgroundView = nil;
                [self.tableView reloadData];
                
                // Load photos for visible rows
                [self loadImagesForOnscreenRows];
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

- (void)terminateAllPhotoDownloads
{
    // Terminate all pending download connections
    NSArray *allDownloads = [_imageDownloadingsList allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [_imageDownloadingsList removeAllObjects];
}

- (void)startDownloadPhoto:(Article *)article forIndexPath:(NSIndexPath *)indexPath
{
    ImageDownloader *imageDownloader = _imageDownloadingsList[indexPath];
    if (imageDownloader == nil) // Avoid re-downloading
    {
        NSLog(@"--- [%@] start downloading photo", article.articleTitle);
        
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.article = article;
        [imageDownloader setCompletionHandler:^{
            if (article.articlePhoto)
            {
                // Display the newly downloaded image
                ImageCell *cell = (ImageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                cell.photoView.image = article.articlePhoto;
            }
            else
            {
                // Downloaded photo is broken
                article.hasPhoto = NO;
                
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            // Remove the ImageDownloader from the in progress list.
            // This will result in it being deallocated.
            [_imageDownloadingsList removeObjectForKey:indexPath];
            
        }];
        _imageDownloadingsList[indexPath] = imageDownloader;
        [imageDownloader startDownload];
    }
    else
    {
        NSLog(@"--- [%@] is downloading photo", article.articleTitle);
    }
}

- (void)loadImagesForOnscreenRows
{
    if (_articles.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Article *article = _articles[indexPath.row];
            if (article.hasPhoto && !article.articlePhoto) // Avoid re-downloading
            {
                [self startDownloadPhoto:article forIndexPath:indexPath];
            }
        }
    }
}

@end
