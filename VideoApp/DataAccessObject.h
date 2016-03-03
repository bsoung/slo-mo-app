//
//  DataAccessObject.h
//  VideoApp
//
//  Created by Benjamin Soung on 2/26/16.
//  Copyright © 2016 Benjamin Soung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataAccessObject : NSObject


- (void)createVideoWithFileAtURL:(NSURL *)url withFileName:(NSString *)filename andDate:(NSDate *)dateNow;
- (NSArray *)fetchVideosFromDatabase;

+ (instancetype)sharedInstance;


@end
