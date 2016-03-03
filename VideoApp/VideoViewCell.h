//
//  VideoViewCell.h
//  VideoApp
//
//  Created by Benjamin Soung on 2/19/16.
//  Copyright © 2016 Benjamin Soung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video+CoreDataProperties.h"

@interface VideoViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *videoCell;

- (void)setUpCellWithVideo:(Video *)video;

@end
