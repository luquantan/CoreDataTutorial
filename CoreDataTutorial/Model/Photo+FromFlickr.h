//
//  Photo+FromFlickr.h
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/12/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import "Photo.h"

@interface Photo (FromFlickr)

//Takes an array of Flickr photoDictonaries. Calls (photoWithFlickrInfor:IntoManagedObjectContext:)
//Also, calls (photographerWithName:intoManagedObjectContext:) 
+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context;

//Take a single photoDictionary and saves it into the context
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context;

@end
