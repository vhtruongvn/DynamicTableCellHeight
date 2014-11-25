//
//  ImageDownloader.m
//  HeadlinesTest
//
//  Created by Ray Vo on 25/11/14.
//  Copyright (c) 2014 Truong Vo. All rights reserved.
//

#import "ImageDownloader.h"
#import "Article.h"

#define kArticlePhotoSize 64

@interface ImageDownloader ()
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@end

@implementation ImageDownloader

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.article.imageHref]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.imageConnection = conn;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

- (void)dealloc
{
    [self cancelDownload];
    [super dealloc];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"[%@] error", self.article.imageHref);
    
    self.activeDownload = nil;
    self.imageConnection = nil;
    
    self.article.articlePhoto = nil;
    
    // Unable to download, inform the delegate
    if (self.completionHandler)
    {
        self.completionHandler();
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"[%@] downloaded", self.article.imageHref);
    
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    if (image.size.width != kArticlePhotoSize || image.size.height != kArticlePhotoSize)
    {
        CGSize itemSize = CGSizeMake(kArticlePhotoSize, kArticlePhotoSize);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [image drawInRect:imageRect];
        self.article.articlePhoto = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else
    {
        self.article.articlePhoto = image;
    }    
    [image release];
    
    self.activeDownload = nil;
    self.imageConnection = nil; // Download is finished, release the connection
    
    // Photo is ready, inform the delegate
    if (self.completionHandler)
    {
        self.completionHandler();
    }
}

@end
