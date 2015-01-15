//
//  Photo+FromFlickr.m
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/12/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo+FromFlickr.h"
#import "Photographer+Create.h"
#import "FlickrFetcher.h"
#import "FlickrWebService.h"

static NSString * const CDTPhotoEntityName = @"Photo";

@implementation Photo (FromFlickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    //Check if photo is already saved
    NSString *uniqueID  = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDTPhotoEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", uniqueID];
    
    //Check for error and matches
    NSError *fetchError;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    
    if (fetchError || [matches count] > 1) {
        NSLog(@"FetchError occured: %@", fetchError.localizedDescription);
    } else if ([matches count]) {
        //A match is found, the same photo is returned.
        photo = [matches firstObject];
    } else {
        //No match. Create new photo
        photo = [NSEntityDescription insertNewObjectForEntityForName:CDTPhotoEntityName inManagedObjectContext:context];
        
        photo.uniqueID = uniqueID;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnail = [self thumbnailForPhoto:photoDictionary];
        
        //Create/Relate to Photographer
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
    }
    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}

+ (NSData *)thumbnailForPhoto:(NSDictionary *)photoDictionary
{
    __block NSData *thumbnailImageData = nil;
    
    NSURL *thumbnailURL = [FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare];
    [FlickrWebService getPhotoAtURL:thumbnailURL withCompletionHandler:^(UIImage *image, NSError *error) {
        thumbnailImageData = UIImageJPEGRepresentation(image, 1.0);
    }];
    
    return thumbnailImageData;
}
@end
