//
//  FlickrWebService.h
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/12/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FlickrWebService : NSObject

@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;

+ (void)getPhotoAtURL:(NSURL *)thumbnailURL withCompletionHandler:(void(^)(UIImage *image, NSError *error))completion;
- (void)startBackgroundFlickrFetch;
- (void)startBackgroundFlickrFetch:(NSTimer *)timer;
- (void)startForegroundFlickrFetchWithCompletion:(void(^)())completion;

@end
