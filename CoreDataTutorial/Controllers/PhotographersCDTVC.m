//
//  PhotographersCDTVC.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotographersCDTVC.h"
#import "Photographer.h"
#import "CDTSharedManagedDocument.h"
#import "PhotoDatabaseAvailability.h"

static NSString * const CDTPhotographerCDTVCReusableCellIdentifier = @"Photographer Cell";

@implementation PhotographersCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.managedObjectContext = [CDTSharedManagedDocument sharedManagedDocument].context;
    }];
    
    //If statement to check for PhotbaseDataBaseAvailability
    if ([CDTSharedManagedDocument sharedManagedDocument].context) {
        self.managedObjectContext = [CDTSharedManagedDocument sharedManagedDocument].context;
    }
    
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];

    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CDTPhotographerCDTVCReusableCellIdentifier];
    
    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photographer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", (int)[photographer.photos count]];
        
    return cell;
}

@end
