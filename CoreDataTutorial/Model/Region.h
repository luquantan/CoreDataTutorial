//
//  Region.h
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/15/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numOfPhotographers;
@property (nonatomic, retain) NSSet *takenBy;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addTakenByObject:(Photographer *)value;
- (void)removeTakenByObject:(Photographer *)value;
- (void)addTakenBy:(NSSet *)values;
- (void)removeTakenBy:(NSSet *)values;

@end
