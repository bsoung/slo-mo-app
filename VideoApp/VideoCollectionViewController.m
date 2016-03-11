//
//  ViewController.m
//  VideoApp
//
//  Created by Benjamin Soung on 2/18/16.
//  Copyright © 2016 Benjamin Soung. All rights reserved.
//


#import "VideoCollectionViewController.h"
#import "SlowMotionViewController.h"
#import "DataAccessObject.h"
#import <PBJVideoPlayer/PBJVideoPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
@import Photos;

@interface VideoCollectionViewController (){
    PBJVideoPlayerController *videoPlayerController;
}

@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (assign, nonatomic) CGSize cellSize;
@property (strong, nonatomic) NSArray *videos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;

@end

@implementation VideoCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    CGFloat size = self.view.frame.size.width / 2.f;
    self.cellSize = CGSizeMake(size, size);
    [flowLayout setItemSize:self.cellSize];
    // Do any additional setup after loading the view, typically from a nib.
    
    // allocate controller
    videoPlayerController = [[PBJVideoPlayerController alloc] init];
    videoPlayerController.delegate = self;
    videoPlayerController.view.frame = self.view.bounds;  

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self fetchVideosFromDatabase];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"Finished. %@", info);
    NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Get documents directory
    NSString *documentsPath = [VideoCollectionViewController applicationDocumentsDirectory];
    NSDate* dateNow = [NSDate date];
    NSTimeInterval timeInterval = [dateNow timeIntervalSinceReferenceDate];
    NSString* intervalAsString = [NSString stringWithFormat:@"%f", timeInterval];
    intervalAsString = [intervalAsString stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *filename = [NSString stringWithFormat:@"/%@.mov", intervalAsString];
    NSString *filePath = [documentsPath stringByAppendingString:filename];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    
    NSError *error = nil;
    
    if (![fileManager moveItemAtURL:mediaUrl toURL:fileUrl error:&error]) {
        NSLog(@"Error moving file %@", error);
    } else {
        
        [[DataAccessObject sharedInstance] createVideoWithFileAtURL:fileUrl withFileName:filename andDate:dateNow];
        
        //getting reference from appDelegate, which is where managed object context is stored
      
        
        //        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[fileUrl absoluteString] error:&error];
        //        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        //        long long fileSize = [fileSizeNumber longLongValue];
        
        //        UIImage *image = [VideoCollectionViewController generateThumbnailIconForVideoFileWith:fileUrl WithSize:self.cellSize];
        //        video.thumbNail = UIImagePNGRepresentation(image);
    }

    [picker dismissViewControllerAnimated:YES completion:^{
         [self fetchVideosFromDatabase];
    }];
        
}

- (void)fetchVideosFromDatabase
{
    self.videos = [[DataAccessObject sharedInstance] fetchVideosFromDatabase];
    [self.collectionView reloadData];

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.videos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
    Video *video = [self.videos objectAtIndex:indexPath.item];
    
    [cell setUpCellWithVideo:video];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  
    Video *video = [self.videos objectAtIndex:indexPath.item];
    if (video) {
        NSString* documentsDirectory = [VideoCollectionViewController applicationDocumentsDirectory];
        NSString* filePath = [documentsDirectory stringByAppendingString:video.filePath];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        NSLog(@"Current URL:%@, pay attention to the APP_ID", fileUrl);
        
        [self startPlaybackForItemWithURL:fileUrl];
    }

}

- (float) getFrameRateFromAVPlayer:(AVPlayer *) player{
    
    float fps = 0.00;
    
    if (player.currentItem.asset) {
        
        AVAssetTrack *assetTrack = [player.currentItem.tracks[0] assetTrack];
        
        if(assetTrack) {
            
            fps = [assetTrack nominalFrameRate];
        }
        
    }
    
    return fps;
}

- (float) getPlayRate:(float) fps {
    
    float rate = 1.0;
    NSString *key = @(fps).stringValue;
    
    NSDictionary *rates = @{
                            @"120" : @0.5,
                            @"60" : @1.0
                            };
    
    if(rates[key]){
        
        NSNumber *storedValue = [rates valueForKey:key];
        rate = [storedValue floatValue];
    }
    
    return rate;
    
}

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer {
    
    PBJVideoView *currentView = (PBJVideoView *) videoPlayer.view;
    
    AVPlayer *player = currentView.player;
    float fps = [self getFrameRateFromAVPlayer:player];
    float rate = [self getPlayRate:fps];
    
    player.rate = rate;
    
    videoPlayer.videoFillMode = AVLayerVideoGravityResizeAspectFill;
    [videoPlayer playFromBeginning];

}

-(void)startPlaybackForItemWithURL:(NSURL *)url {
 
    videoPlayerController.videoPath = [url absoluteString];
    
    [self addChildViewController:videoPlayerController];
    [self.view addSubview:videoPlayerController.view];
    [videoPlayerController didMoveToParentViewController:self];

    
}

//-(void)playerDidFinishPlaying:(NSNotification *)notification
//{
//    NSLog(@"Playback ended.");
////    [AVPlayerViewController dismissViewControllerAnimated:YES completion:^{
////        [self fetchVideosFromDatabase];
////    }];
//    
//}



+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SlowMotionViewController* smVC = segue.destinationViewController;
    smVC.cellSize = self.cellSize;
}

@end
