//
//  SlowMotionViewController.m
//  VideoApp
//
//  Created by Benjamin Soung on 2/25/16.
//  Copyright © 2016 Benjamin Soung. All rights reserved.
//

#import "SlowMotionViewController.h"
#import "TTMAVCaptureManager.h"
#import "VideoCollectionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SlowMotionViewController () <TTMAVCaptureManagerDelegate>
{
    NSTimeInterval startTime;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (assign, nonatomic) NSTimer *timer;
@property (strong, nonatomic) TTMAVCaptureManager *captureManager;

@property (weak, nonatomic) IBOutlet UIButton *oneTwentyFPSButton;
@property (weak, nonatomic) IBOutlet UIButton *sixtyFPSButton;
@property (weak, nonatomic) IBOutlet UIButton *defaultFPSButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

- (IBAction)recordButtonTouchUpInside:(id)sender;
- (IBAction)sixtyFPSButtonTouchUpInside:(id)sender;
- (IBAction)oneTwentyFPSButtonTouchUpInside:(id)sender;
- (IBAction)defaultFPSButtonTouchUpInside:(id)sender;

@end

@implementation SlowMotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if(!self.captureManager) {
        self.captureManager = [[TTMAVCaptureManager alloc] initWithPreviewView:self.previewView mode:TTMOutputModeVideoData];
        self.captureManager.delegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVCaptureManagerDeleagte

- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
    
    
    if (error) {
        NSLog(@"error:%@", error);
        return;
    }
    
    NSLog(@"File url: %@", outputFileURL);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Get documents directory
    NSString *documentsPath = [SlowMotionViewController applicationDocumentsDirectory];
    NSDate* dateNow = [NSDate date];
    NSTimeInterval timeInterval = [dateNow timeIntervalSinceReferenceDate];
    NSString* intervalAsString = [NSString stringWithFormat:@"%f", timeInterval];
    intervalAsString = [intervalAsString stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *filename = [NSString stringWithFormat:@"/%@.mov", intervalAsString];
    NSString *filePath = [documentsPath stringByAppendingString:filename];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    
    error = nil;
    
    if (![fileManager moveItemAtURL:outputFileURL toURL:fileUrl error:&error]) {
        NSLog(@"Error moving file %@", error);
    } else {
        //getting reference from appDelegate, which is where managed object context is stored
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        Video *video = (Video *)[NSEntityDescription insertNewObjectForEntityForName:@"Video"
                                                              inManagedObjectContext:[appDelegate managedObjectContext]];
        video.filePath = filename;
        video.title = @"Title";
        video.comment = @"Description";
        video.date = dateNow;
        
        //        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[fileUrl absoluteString] error:&error];
        //        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        //        long long fileSize = [fileSizeNumber longLongValue];
        
        UIImage *image = [SlowMotionViewController generateThumbnailIconForVideoFileWith:fileUrl WithSize:self.cellSize];
        video.thumbNail = UIImagePNGRepresentation(image);
        
        [appDelegate saveContext];
    }
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    [assetLibrary writeVideoAtPathToSavedPhotosAlbum:fileUrl
                                     completionBlock:
     ^(NSURL *assetURL, NSError *error) {}];


    
//    [self saveRecordedFile:outputFileURL];
}

#pragma mark - Timer Handler

- (void)timerHandler:(NSTimer *)timer {
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval recorded = current - startTime;
    
    self.timeStamp.text = [NSString stringWithFormat:@"%.2f", recorded];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)recordButtonTouchUpInside:(id)sender {
    // REC START
    if (!self.captureManager.isRecording) {
        
        // change UI
//        [self.recordButton setImage:self.recStopImage
//                     forState:UIControlStateNormal];
//
        
        // timer start
        startTime = [[NSDate date] timeIntervalSince1970];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(timerHandler:)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [self.captureManager startRecording];
    }
    // REC STOP
    else {
        
//        isNeededToSave = YES;
        [self.captureManager stopRecording];
        
        [self.timer invalidate];
        self.timer = nil;
        
        // change UI
//        [self.recBtn setImage:self.recStartImage
//                     forState:UIControlStateNormal];
//       
    }
}

- (IBAction)sixtyFPSButtonTouchUpInside:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.captureManager switchFormatWithDesiredFPS:60];
    });
}

- (IBAction)oneTwentyFPSButtonTouchUpInside:(id)sender {
   
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.captureManager switchFormatWithDesiredFPS:240];
    });
}


- (IBAction)defaultFPSButtonTouchUpInside:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.captureManager switchFormatWithDesiredFPS:30];
    });
}




+ (UIImage *)generateThumbnailIconForVideoFileWith:(NSURL *)contentURL WithSize:(CGSize)size
{
    UIImage *theImage = nil;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:contentURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize=size;
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(100,100); //change whatever you want here.
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    theImage = [[UIImage alloc] initWithCGImage:imgRef] ;
    CGImageRelease(imgRef);
    return theImage;
}

+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

//- (void)SlowMotion:(NSURL *)URl
//{
//    AVURLAsset* videoAsset = [AVURLAsset URLAssetWithURL:URl options:nil]; //self.inputAsset;
//    
//    AVAsset *currentAsset = [AVAsset assetWithURL:URl];
//    AVAssetTrack *vdoTrack = [[currentAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    //create mutable composition
//    AVMutableComposition *mixComposition = [AVMutableComposition composition];
//    
//    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    NSError *videoInsertError = nil;
//    BOOL videoInsertResult = [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
//                                                            ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
//                                                             atTime:kCMTimeZero
//                                                              error:&videoInsertError];
//    if (!videoInsertResult || nil != videoInsertError) {
//        //handle error
//        return;
//    }
//
//NSError *audioInsertError =nil;
//BOOL audioInsertResult =[compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
//                                                       ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
//                                                        atTime:kCMTimeZero
//                                                         error:&audioInsertError];
//
//if (!audioInsertResult || nil != audioInsertError) {
//    //handle error
//    return;
//}
//
//CMTime duration =kCMTimeZero;
//duration=CMTimeAdd(duration, currentAsset.duration);
////slow down whole video by 2.0
//double videoScaleFactor = 2.0;
//CMTime videoDuration = videoAsset.duration;
//
//[compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
//                           toDuration:CMTimeMake(videoDuration.value*videoScaleFactor, videoDuration.timescale)];
//[compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
//                           toDuration:CMTimeMake(videoDuration.value*videoScaleFactor, videoDuration.timescale)];
//[compositionVideoTrack setPreferredTransform:vdoTrack.preferredTransform];
//
//    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//NSString *docsDir = [dirPaths objectAtIndex:0];
//NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"slowMotion.mov"]];
//if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
//[[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
//NSURL *_filePath = [NSURL fileURLWithPath:outputFilePath];
//
////export
//AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
//                                                                     presetName:AVAssetExportPresetLowQuality];
//assetExport.outputURL=_filePath;
//assetExport.outputFileType =           AVFileTypeQuickTimeMovie;
//exporter.shouldOptimizeForNetworkUse = YES;
//[assetExport exportAsynchronouslyWithCompletionHandler:^
// {
//     
//     switch ([assetExport status]) {
//         case AVAssetExportSessionStatusFailed:
//         {
//             NSLog(@"Export session faiied with error: %@", [assetExport error]);
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 // completion(nil);
//             });
//         }
//             break;
//         case AVAssetExportSessionStatusCompleted:
//         {
//             
//             NSLog(@"Successful");
//             NSURL *outputURL = assetExport.outputURL;
//             
//             ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//             if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
//                 
//                 [self writeExportedVideoToAssetsLibrary:outputURL];
//             }
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 //                                            completion(_filePath);
//             });
//             
//         }
//             break;
//         default:
//             
//             break;
//     }
//     
//     
// }];
//    
//- (void)writeExportedVideoToAssetsLibrary :(NSURL *)url {
//        NSURL *exportURL = url;
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL]) {
//            [library writeVideoAtPathToSavedPhotosAlbum:exportURL completionBlock:^(NSURL *assetURL, NSError *error){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (error) {
//                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
//                                                                            message:[error localizedRecoverySuggestion]
//                                                                           delegate:nil
//                                                                  cancelButtonTitle:@"OK"
//                                                                  otherButtonTitles:nil];
//                        [alertView show];
//                    }
//                    if(!error)
//                    {
//                        // [activityView setHidden:YES];
//                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sucess"
//                                                                            message:@"video added to gallery successfully"
//                                                                           delegate:nil
//                                                                  cancelButtonTitle:@"OK"
//                                                                  otherButtonTitles:nil];
//                        [alertView show];
//                    }
//#if !TARGET_IPHONE_SIMULATOR
//                    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
//#endif
//                });
//            }];
//        } else {
//            NSLog(@"Video could not be exported to assets library.");
//        }
//        
//   }
//}
@end
