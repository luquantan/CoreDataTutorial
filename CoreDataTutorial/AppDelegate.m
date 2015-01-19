//
//  AppDelegate.m
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/9/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrWebService.h"
#import "CDTSharedManagedDocument.h"

static NSInteger const CDTForegroundFlickrFetchInterval = 20 * 60;

@interface AppDelegate ()
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;
@property (strong, nonatomic) FlickrWebService *flickrWebService;
@property (strong, nonatomic) NSTimer *flickrFetchTimer;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Call CDTSharedManagedDocument right at the start of the app so that when other parts of the app call the context, it will be available.
    self.photoDatabaseContext = [CDTSharedManagedDocument sharedManagedDocument].context;
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [self.flickrWebService startBackgroundFlickrFetch];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.flickrWebService startForegroundFlickrFetchWithCompletion:completionHandler];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.flickrWebService.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

#pragma mark - Initialize FlickrWebService
- (FlickrWebService *)flickrWebService
{
    if (!_flickrWebService) {
        _flickrWebService = [[FlickrWebService alloc] init];
    }
    return _flickrWebService;
}

#pragma mark - setter/getter for photoDatabaseContext
- (void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext
{
    _photoDatabaseContext = photoDatabaseContext;
    
    [self.flickrFetchTimer invalidate];
    self.flickrFetchTimer = nil;
    
    if (self.photoDatabaseContext) {
        self.flickrFetchTimer = [NSTimer scheduledTimerWithTimeInterval:CDTForegroundFlickrFetchInterval target:self.flickrWebService selector:@selector(startBackgroundFlickrFetch) userInfo:nil repeats:YES];
    }
    
}
@end
