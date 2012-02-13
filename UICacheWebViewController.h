//
//  UICacheWebViewController.h
//  Pinjiuge
//
//  Created by B.H.Liu appublisher on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIWebPageRequest.h"
#import "ASIDownloadCache.h"


@interface UICacheWebViewController : UIViewController<UIWebViewDelegate,ASIHTTPRequestDelegate>

@property (nonatomic,retain) ASIWebPageRequest * request;
@property (nonatomic,retain) UIWebView *cacheWebView;
@property (nonatomic,retain) NSURL *url;
@property (nonatomic,assign) BOOL isCache;

- (void)loadURL:(NSURL*)url withCache:(BOOL)cached;
- (void)loadURL:(NSURL*)url withCache:(BOOL)cached firstFromFile:(NSString*)path;

- (void)webPageFetchStarted:(ASIHTTPRequest*)theRequest;
- (void)webPageFetchFailed:(ASIHTTPRequest *)theRequest;
- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest;

@end
