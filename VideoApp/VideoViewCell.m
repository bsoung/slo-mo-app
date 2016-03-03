//
//  VideoViewCell.m
//  VideoApp
//
//  Created by Benjamin Soung on 2/19/16.
//  Copyright © 2016 Benjamin Soung. All rights reserved.
//

#import "VideoViewCell.h"

@implementation VideoViewCell

- (void)setUpCellWithVideo:(Video *)video;
{
    UIImage *image = [UIImage imageWithData:video.thumbNail];
    self.videoCell.image = image;
}

@end
