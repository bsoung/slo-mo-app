//
//  Video+CoreDataProperties.h
//  VideoApp
//
//  Created by Benjamin Soung on 2/19/16.
//  Copyright © 2016 Benjamin Soung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Video.h"

NS_ASSUME_NONNULL_BEGIN

@interface Video (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *filePath;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *comment;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSData *thumbNail;

@end

NS_ASSUME_NONNULL_END
