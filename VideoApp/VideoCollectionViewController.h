//
//  ViewController.h
//  VideoApp
//
//  Created by Benjamin Soung on 2/18/16.
//  Copyright © 2016 Benjamin Soung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Video+CoreDataProperties.h"
#import "AppDelegate.h"
#import "VideoViewCell.h"

@interface VideoCollectionViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>


@end

