//
//  CDTSharedManagedDocument.h
//  CoreDataTutorial
//
//  Created by LuQuan Intrepid on 1/12/15.
//  Copyright (c) 2015 LuQuan Intrepid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CDTSharedManagedDocument : NSObject

+ (instancetype)sharedManagedDocument;

@property (strong, nonatomic) NSManagedObjectContext *context;

@end
