//
//  Photographer+Create.h
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/12/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

//Create a photographer object. Searches CoreData for photographer with similar name, if not found, new Photographer is created.
+ (Photographer *)photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
