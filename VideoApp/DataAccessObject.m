//
//  DataAccessObject.m
//  VideoApp
//
//  Created by Benjamin Soung on 2/26/16.
//  Copyright © 2016 Benjamin Soung. All rights reserved.
//

#import "DataAccessObject.h"
#import <CoreData/CoreData.h>
#import "Video+CoreDataProperties.h"
#import "AppDelegate.h"


@implementation DataAccessObject

+ (instancetype)sharedInstance
{
    static DataAccessObject *instance;
    
    //# of times, only once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      instance = [[DataAccessObject alloc] init];
                      
                  });
    
    return instance;
    
}

- (void)createVideoWithFileAtURL:(NSURL *)url withFileName:(NSString *)filename andDate:(NSDate *)dateNow
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    Video *video = (Video *)[NSEntityDescription insertNewObjectForEntityForName:@"Video"
                                                          inManagedObjectContext:[appDelegate managedObjectContext]];
    video.filePath = filename;
    video.title = @"Title";
    video.comment = @"Description";
    video.date = dateNow;
    
    [appDelegate saveContext];

}

- (NSArray *)fetchVideosFromDatabase {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Cannot fetch objects %@", error);
    } else {
        return fetchedObjects;
    }
    
    return nil;
}




@end
