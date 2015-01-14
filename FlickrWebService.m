//
//  FlickrWebService.m
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/12/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import <Coredata/CoreData.h>
#import "FlickrFetcher.h"
#import "FlickrWebService.h"
#import "Photo+FromFlickr.h"
#import "CDTSharedManagedDocument.h"

static NSString * const CDTFlickrFetchNSURLDownloadTaskIdentifer = @"CDTFlickrFetchNSURLDownloadTaskIdentifer";
static NSInteger const CDTBackgroundFlickrFetchTimeout = 10;

@interface FlickrWebService() <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSURL *flickrURL;
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;
@end

@implementation FlickrWebService

// standard "get photo information from Flickr URL" code

- (NSURL *)flickrURL
{
    if (!_flickrURL) {
        _flickrURL = [FlickrFetcher URLforRecentGeoreferencedPhotos];
    }
    return _flickrURL;
}

- (NSManagedObjectContext *)photoDatabaseContext
{
    if (!_photoDatabaseContext) {
        _photoDatabaseContext = [CDTSharedManagedDocument sharedManagedDocument].context;
    }
    return _photoDatabaseContext;
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];  // will block if url is not local!
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

#pragma mark - Starting a fetch from Flickr

- (void)startBackgroundFlickrFetch
{
    // getTasksWithCompletionHandler: is ASYNCHRONOUS
    // but that's okay because we're not expecting startFlickrFetch to do anything synchronously anyway
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        // let's see if we're already working on a fetch ...
        if (![downloadTasks count]) {
            // ... not working on a fetch, let's start one up
            NSURLSessionDownloadTask *task =    [self.flickrDownloadSession downloadTaskWithURL:self.flickrURL];
            task.taskDescription = CDTFlickrFetchNSURLDownloadTaskIdentifer;
            [task resume];
        } else {
            // ... we are working on a fetch (let's make sure it (they) is (are) running while we're here)
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (void)startBackgroundFlickrFetch:(NSTimer *)timer // NSTimer target/action always takes an NSTimer as an argument
{
    [self startBackgroundFlickrFetch];
}

- (void)startForegroundFlickrFetchWithCompletion:(void(^)())completion
{
    if (self.photoDatabaseContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = CDTBackgroundFlickrFetchTimeout; // want to be a good background citizen!
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.flickrURL];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                completion(UIBackgroundFetchResultNoData);
            } else {
                [self loadFlickrPhotosFromLocalURL:localFile intoContext:self.photoDatabaseContext andThenExecuteBlock:^{
                    completion(UIBackgroundFetchResultNewData);
                }
                 ];
            }
        }];
        [task resume];
    } else {
        completion(UIBackgroundFetchResultNoData); // no app-switcher update if no database!
    }
}

#pragma mark - NSURLSession

- (NSURLSession *)flickrDownloadSession
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfirguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:CDTFlickrFetchNSURLDownloadTaskIdentifer];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfirguration delegate:self delegateQueue:nil];
        });
    }
    
    return _flickrDownloadSession;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localURL intoContext:(NSManagedObjectContext *)context andThenExecuteBlock:(void(^)())whenDone
{
    if (context) {
        NSArray *photos = [self flickrPhotosAtURL:localURL];
        [context performBlock:^{
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            if (whenDone) whenDone();
        }];
    } else {
        if (whenDone) whenDone();
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile
{
    // we shouldn't assume we're the only downloading going on ...
    if ([downloadTask.taskDescription isEqualToString:CDTFlickrFetchNSURLDownloadTaskIdentifer]) {
        // ... but if this is the Flickr fetching, then process the returned data
        [self loadFlickrPhotosFromLocalURL:localFile intoContext:self.photoDatabaseContext andThenExecuteBlock:^{
            [self flickrDownloadTasksMightBeComplete];
        }];
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // we don't support resuming an interrupted download task
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // we don't report the progress of a download in our UI, but this is /  a cool method to do that with
}

// not required by the protocol, but we should definitely catch errors here
// so that we can avoid crashes
// and also so that we can detect that download tasks are (might be) complete
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error && (session == self.flickrDownloadSession)) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self flickrDownloadTasksMightBeComplete];
    }
}

// this is "might" in case some day we have multiple downloads going on at once

- (void)flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            // we're doing this check for other downloads just to be theoretically "correct"
            //  but we don't actually need it (since we only ever fire off one download task at a time)
            // in addition, note that getTasksWithCompletionHandler: is ASYNCHRONOUS
            //  so we must check again when the block executes if the handler is still not nil
            //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
            if (![downloadTasks count]) {  // any more Flickr downloads left?
                // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            } // else other downloads going, so let them call this method when they finish
        }];
    }
}

@end
