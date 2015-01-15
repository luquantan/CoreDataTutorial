//
//  CDTSharedManagedDocument.m
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/12/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import "CDTSharedManagedDocument.h"
#import "PhotoDatabaseAvailability.h"

@interface CDTSharedManagedDocument()
@property (strong, nonatomic) NSURL *managedDocumentURL;
@property (strong, nonatomic) UIManagedDocument *managedDocument;
@end

@implementation CDTSharedManagedDocument

+ (instancetype)sharedManagedDocument
{
    static CDTSharedManagedDocument *sharedDocument = nil;
    static dispatch_once_t singleToken;
    dispatch_once(&singleToken, ^{
        sharedDocument = [[self alloc] init];
    });
    return sharedDocument;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createManagedDocument];
    }
    
    return self;
}

#pragma mark - UIManagedDocument
- (void)createManagedDocument
{
    UIManagedDocument *managedDocument = [[UIManagedDocument alloc] initWithFileURL:self.managedDocumentURL];
    self.managedDocument = managedDocument;
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.managedDocumentURL path]];
    
    if (fileExists) {
        [managedDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self getContextFromManagedDocument];
                [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self];
            } else {
                NSLog(@"Couldn't open document at %@", self.managedDocumentURL);
            }
        }];
    } else {
        [managedDocument saveToURL:managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                [self getContextFromManagedDocument];
                [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self];
            } else {
                NSLog(@"Couldn't create document at %@", self.managedDocumentURL);
            }
        }];
    }
}

- (void)createURLForManagedDocument
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"DataModel";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    
    self.managedDocumentURL = url;
}

- (void)getContextFromManagedDocument
{
    if (self.managedDocument.documentState == UIDocumentStateNormal) {
        self.context = self.managedDocument.managedObjectContext;
    } else {
        NSLog(@"Could not get context from ManagedDocument");
    }
}

#pragma mark - setter/getter for properties

- (NSURL *)managedDocumentURL
{
    if (!_managedDocumentURL) {
        [self createURLForManagedDocument];
    }
    return _managedDocumentURL;
}
@end
