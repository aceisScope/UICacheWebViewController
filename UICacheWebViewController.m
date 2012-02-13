//
//  UICacheWebViewController.m
//  Pinjiuge
//
//  Created by B.H.Liu appublisher on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UICacheWebViewController.h"
#import "Reachability.h"

@implementation UICacheWebViewController
@synthesize request=_request;
@synthesize cacheWebView=_cacheWebView;
@synthesize isCache=_isCache;
@synthesize url=_url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isCache = YES;
        self.request = [ASIWebPageRequest requestWithURL:nil];
        [self.request setDelegate:self];
        self.url=[[NSURL URLWithString:nil] autorelease];
    }
    return self;
}

- (void)dealloc
{
    self.cacheWebView = nil;
    self.url = nil;
    self.request = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.cacheWebView = [[[UIWebView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)] autorelease];
    self.cacheWebView.opaque = NO;
    self.cacheWebView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.cacheWebView];
    self.cacheWebView.delegate = self;

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    /////////////注：以下代码需放到需要的子类中，切记！！！
    /*
    [self.cacheWebView stopLoading];
    if ([self request]) 
    {
        [[self request] setDelegate:nil];
        [[self request] cancel];
    }
     */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadURL:(NSURL*)url withCache:(BOOL)cached firstFromFile:(NSString*)path
{
    //if cache shall be used
    self.isCache = cached;
    
    self.url = url;
    
    // Assume request is a property of our controller
    // First, we'll cancel any in-progress page load
    [[self request] setDelegate:nil];
    [[self request] cancel];
    
    
    [self setRequest:[ASIWebPageRequest requestWithURL:url]];
    
    [[self request] setDelegate:self];
    [[self request] setDidStartSelector:@selector(webPageFetchStarted:)];
    [[self request] setDidFailSelector:@selector(webPageFetchFailed:)];
    [[self request] setDidFinishSelector:@selector(webPageFetchSucceeded:)];
    
    // Tell the request to embed external resources directly in the page
    [[self request] setUrlReplacementMode:ASIReplaceExternalResourcesWithData];
    
    [[self request] setDownloadCache:[ASIDownloadCache sharedCache]];
    /////永久缓存，以防一次会话结束后缓存就被清空
    [self.request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [[self request] setDownloadDestinationPath:
     [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:[self request]]];
    
    
    //////no internet connection
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) 
    {
        NSLog(@"internet irreachable");
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.request downloadDestinationPath]]) 
        {
            NSLog(@"no internet and cache exists and load from cache file directly");
            [self.cacheWebView loadHTMLString:[NSString stringWithContentsOfFile:[self.request downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
        }
        else
        {
            NSLog(@"no internet and cache not exist,load from file directly");
            [self.cacheWebView loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:[[NSBundle mainBundle]resourceURL]];
        }
    }
    //////with internet connection
    else if ([[url absoluteString] length] == 0)
    {
        NSLog(@"with internet but json parse not finished yet, load from file directly");
        [self.cacheWebView loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:[[NSBundle mainBundle]resourceURL]];
    }
    else
    {
        NSString * thePath = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(),[[self.url pathComponents] objectAtIndex:[self.url pathComponents].count-1]];
        /////内容无更新,且缓存完毕,直接从文件加载
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.request downloadDestinationPath]]&&![[NSFileManager defaultManager] fileExistsAtPath:thePath]) 
        {
            NSLog(@"with internet and cache exists and stuff not altered and load from cache file directly");
            [self.cacheWebView loadHTMLString:[NSString stringWithContentsOfFile:[self.request downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
            
        }
        /////内容有更新，或者不完整，从文件加载，同时进行缓存
        else
        {            
            ////创建文件,成功后删除,若文件存在,则说明没有下载完毕
            [[NSFileManager defaultManager] createDirectoryAtPath:thePath withIntermediateDirectories:YES attributes:nil error:nil];
            
            [self.request startAsynchronous];
        }
    }

}

- (void)loadURL:(NSURL *)url withCache:(BOOL)cached
{
    //if cache shall be used
    self.isCache = cached;
    
    self.url = url;
    
    // Assume request is a property of our controller
    // First, we'll cancel any in-progress page load
    [[self request] setDelegate:nil];
    [[self request] cancel];
    
    
    [self setRequest:[ASIWebPageRequest requestWithURL:url]];
    
    [[self request] setDelegate:self];
    [[self request] setDidFailSelector:@selector(webPageFetchFailed:)];
    [[self request] setDidFinishSelector:@selector(webPageFetchSucceeded:)];
    
    // Tell the request to embed external resources directly in the page
    [[self request] setUrlReplacementMode:ASIReplaceExternalResourcesWithData];
    
    [[self request] setDownloadCache:[ASIDownloadCache sharedCache]];
    /////永久缓存，以防一次会话结束后缓存就被清空
    [self.request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [[self request] setDownloadDestinationPath:
     [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:[self request]]];
    
    
    //////no internet connection
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) 
    {
        NSLog(@"internet irreachable");
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.request downloadDestinationPath]]) 
        {
            NSLog(@"no internet and cache exists and load from cache file directly");
            [self.cacheWebView loadHTMLString:[NSString stringWithContentsOfFile:[self.request downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
        }
        else
        {
            NSLog(@"cache not exist");
        }
    }
    //////with internet connection
    else
    {
        NSString * path = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(),[[self.url pathComponents] objectAtIndex:[self.url pathComponents].count-1]];
        NSLog(@"path %@",path);
        /////内容无更新,且缓存完毕,直接从文件加载
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.request downloadDestinationPath]]&&![[NSFileManager defaultManager] fileExistsAtPath:path]) 
        {
            NSLog(@"with internet and cache exists and stuff not altered and load from cache file directly");
            
            [self.cacheWebView loadHTMLString:[NSString stringWithContentsOfFile:[self.request downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:NSHomeDirectory()]];

        }
         /////内容有更新，或者不完整，从服务器加载，同时进行缓存
        else
        {
            ////在缓存的同时，请求url进行加载 
            [self.cacheWebView loadRequest:[NSURLRequest requestWithURL:url]];
            
//            ////创建文件,成功后删除,若文件存在,则说明没有下载完毕
//            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            
            [self.request startAsynchronous];
        }
    }
}

- (void)webPageFetchStarted:(ASIHTTPRequest*)theRequest
{
    NSString * path = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(),[[self.url pathComponents] objectAtIndex:[self.url pathComponents].count-1]];
    ////创建文件,成功后删除,若文件存在,则说明没有下载完毕
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSLog(@"cache web view request started");
}


- (void)webPageFetchFailed:(ASIHTTPRequest *)theRequest
{
    // Obviously you should handle the error properly...
    NSLog(@"cache web view request error:%@",[theRequest error]);
    
    NSString * path = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(),[[self.url pathComponents] objectAtIndex:[self.url pathComponents].count-1]];
    ////确保证明缓存未完成的文件是存在的
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest
{
    NSLog(@"cache web view succeeded");
    NSString *response = [NSString stringWithContentsOfFile:
                          [theRequest downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil];
    // Note we're setting the baseURL to the url of the page we downloaded. This is important!
    [self.cacheWebView loadHTMLString:response baseURL:[theRequest url]];
    
    //////缓存成功则删除临时文件
    NSFileManager* defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:[NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(),[[self.url pathComponents] objectAtIndex:[self.url pathComponents].count-1]] error:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

}

@end
