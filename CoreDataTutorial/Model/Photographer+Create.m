//
//  Photographer+Create.m
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/12/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import "Photographer+Create.h"

static NSString * const CDTPhotographerEntityName = @"Photographer";

@implementation Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    if ([name length]) {
        //Check whether this photographer exists in CoreData
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDTPhotographerEntityName];
        request.predicate = [NSPredicate predicateWithFormat:@"name  = %@", name];
        
        //Check for errors in fetch request and the number of matches from the fetch request
        NSError *fetchError;
        NSArray *matches = [context executeFetchRequest:request error:&fetchError];
        
        if (fetchError || [matches count] > 1) {
            NSLog(@"FetchError occured: %@ ",fetchError.localizedDescription);
        } else if (![matches count]) {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:CDTPhotographerEntityName inManagedObjectContext:context];
            photographer.name = name;
        } else {
            //A match has been found, return same photographer
            photographer = [matches lastObject]; //WHY LASTOBJECT INSTEAD OF FIRST OBJECT
        }
    } else {
        NSLog(@"No input string for photographer name");
    }
    return photographer;
}

- (NSNumber *)numOfPhotosTaken
{
    return [NSNumber numberWithUnsignedInteger:[self.photos count]];
}

@end
