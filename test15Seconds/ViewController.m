//
//  ViewController.m
//  test15Seconds
//
//  Created by Tommy on 2016-02-11.
//  Copyright © 2016 jxh. All rights reserved.
//

#import "ViewController.h"
#import "THVideoItem.h"
#import "VideoItemCell.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVCompositionTrack.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import "THAudioItem.h"
#import "THTransitionInstructions.h"
#import "THVideoTransition.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray *musicItems;
@property (strong, nonatomic) NSArray *voiceOverItems;
@property (strong, nonatomic) NSArray *allAudioItems;
@property (strong, nonatomic) NSArray *videoItems;

@property (strong, nonatomic) NSMutableArray *videoReadyPools;
@property (strong, nonatomic) NSMutableArray *audioReadyPools;

@property (weak, nonatomic) IBOutlet UITableView *videoTable;
@property (weak, nonatomic) IBOutlet UITableView *musicTable;
@property (weak, nonatomic) IBOutlet UITableView *commentaryTable;

@property (weak, nonatomic) IBOutlet UICollectionView *PoolCollectionView;

@property (strong, nonatomic) AVMutableComposition *composition;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVPlayerItem *playSession;
@property(strong, nonatomic)NSMutableArray *transitionLists;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    for (NSURL *url in [self voiceOverURLs]) {
//        NSLog(@"%@", [[url lastPathComponent] copy]);
//    }
    self.videoTable.dataSource = self;
    self.videoTable.delegate = self;
    self.musicTable.dataSource = self;
    self.musicTable.delegate = self;
    self.commentaryTable.dataSource = self;
    self.PoolCollectionView.dataSource = self;
    self.videoReadyPools = [[NSMutableArray alloc]init];
    self.audioReadyPools = [[NSMutableArray alloc]init];
    [self setUpCellSize];
    
    self.composition = [AVMutableComposition composition];
    
    self.transitionLists = [[NSMutableArray alloc] init];
    THVideoTransition *transition = [THVideoTransition disolveTransitionWithDuration:CMTimeMake(2, 1)];
    transition.type = THVideoTransitionTypePush;
    [self.transitionLists addObject:transition];
    THVideoTransition *transition1 = [THVideoTransition disolveTransitionWithDuration:CMTimeMake(2, 1)];
    transition1.type = THVideoTransitionTypePush;
    [self.transitionLists addObject:transition1];
}

- (NSArray *)videoURLs {
    NSMutableArray *urls = [NSMutableArray array];
    [urls addObjectsFromArray:[[NSBundle mainBundle] URLsForResourcesWithExtension:@"mov" subdirectory:nil]];
    [urls addObjectsFromArray:[[NSBundle mainBundle] URLsForResourcesWithExtension:@"mp4" subdirectory:nil]];
    return urls;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSArray *)musicURLs {
    return [[NSBundle mainBundle] URLsForResourcesWithExtension:@"m4a" subdirectory:nil];
}
//VoiceOvers文件夹中的音频文件
- (NSArray *)voiceOverURLs {
    return [[NSBundle mainBundle] URLsForResourcesWithExtension:@"m4a" subdirectory:@"VoiceOvers"];
}

- (NSArray *)videoItems {
    if (!_videoItems) {
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 0; i < [self videoURLs].count; i++) {
            NSURL *url = [self videoURLs][i];
            THVideoItem *item = [THVideoItem videoItemWithURL:url];
            [item prepareWithCompletionBlock:^(BOOL complete) {
                if (complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.videoTable reloadData];
                    });
                } else {
                }
            }];
            [items addObject:item];
        }
        _videoItems = items;
    }
    return _videoItems;
}

- (NSArray *)musicItems {
    if (!_musicItems) {
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 0; i < [self musicURLs].count; i++) {
            NSURL *url = [self musicURLs][i];
            THAudioItem *item = [THAudioItem audioItemWithURL:url];
            [item prepareWithCompletionBlock:NULL];
            [items addObject:item];
        }
        _musicItems = items;
    }
    return _musicItems;
}
#pragma tableView delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger itemCount = 0;
    if (tableView.tag == 1) {
        itemCount = self.videoItems.count;
    }else if (tableView.tag == 2){
        itemCount = self.musicItems.count;
        
    }else{
        itemCount = self.voiceOverItems.count;
    }
    return itemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (tableView.tag == 1) {
        THVideoItem *item = self.videoItems[indexPath.row];
        cell.textLabel.text = item.filename;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2lld", item.timeRange.duration.value /60000];
        cell.imageView.image = [item.thumbnails firstObject];
        
    }else if (tableView.tag == 2){
        THAudioItem *item = self.musicItems[indexPath.row];
        cell.textLabel.text = item.filename;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2lld", item.timeRange.duration.value /60000];
    }else{
        
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1) {
        [self addTimelineItem:self.videoItems[indexPath.row] toTrack:THVideoTrack];
        
    }else if (tableView.tag == 2){
        [self addTimelineItem:self.musicItems[indexPath.row] toTrack:THMusicTrack];
    }else{
        
    }
    
}
- (void)addTimelineItem:(THVideoItem *)timelineItem toTrack:(THTrack)track {
    
    if (track == THVideoTrack) {
        
        [self.videoReadyPools addObject:timelineItem];
        
        NSIndexPath *path = [NSIndexPath indexPathForItem:(self.videoReadyPools.count - 1) inSection:0];
        [self.PoolCollectionView insertItemsAtIndexPaths:@[path]];

    }else{
        [self.audioReadyPools addObject:timelineItem];
    }

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.videoReadyPools.count;
    

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoItemCell *cell = (VideoItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    THVideoItem *model = self.videoReadyPools[indexPath.row];
    cell.duration.text = [NSString stringWithFormat:@"%.2llds", model.timeRange.duration.value /60000];
    cell.fileName.text = model.filename;
    return cell;
}

-(void)setUpCellSize{
    CGFloat width = CGRectGetWidth(self.PoolCollectionView.frame);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.PoolCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(width / 3, width / 4);
}

-(void)addTrack2Composition:(NSArray *)items Type:(NSString *)type{
    //在这里添加过场视频动画

    if(type == AVMediaTypeVideo){
        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
        
        AVMutableCompositionTrack *compositionTrackA =                          // 1
        [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                      preferredTrackID:trackID];
        
        AVMutableCompositionTrack *compositionTrackB =
        [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                      preferredTrackID:trackID];
        
        NSArray *videoTracks = @[compositionTrackA, compositionTrackB];
        
        CMTime cursorTime = kCMTimeZero;
        CMTime transitionDuration = kCMTimeZero;
        transitionDuration = CMTimeMake(2, 1);
        
        NSArray *videos = self.videoReadyPools;
        
        for (NSUInteger i = 0; i < videos.count; i++) {
            
            NSUInteger trackIndex = i % 2;                                      // 3
            
            THVideoItem *item = videos[i];
            AVMutableCompositionTrack *currentTrack = videoTracks[trackIndex];
            
            AVAssetTrack *assetTrack =
            [[item.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            
            [currentTrack insertTimeRange:item.timeRange
                                  ofTrack:assetTrack
                                   atTime:cursorTime error:nil];
            
            // Overlap clips by transition duration                             // 4
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
            cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
        }
    }else{
    
        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
        
        AVMutableCompositionTrack *compositionTrack =                       // 2
        [self.composition addMutableTrackWithMediaType:type preferredTrackID:trackID];
        // Set insert cursor to 0
        CMTime cursorTime = kCMTimeZero;                                    // 3
        
        for (THVideoItem *item in items) {
            
            
            
            AVAssetTrack *assetTrack =                                      // 5
            [[item.asset tracksWithMediaType:type] firstObject];
            
            [compositionTrack insertTimeRange:item.timeRange                // 6
                                      ofTrack:assetTrack
                                       atTime:cursorTime
                                        error:nil];
            
            // Move cursor to next item time
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);    // 7
        }
    }
    
}
- (AVVideoComposition *)buildVideoComposition {
    
    AVVideoComposition *videoComposition =                                  // 1
    [AVMutableVideoComposition
     videoCompositionWithPropertiesOfAsset:self.composition];
    
    NSArray *transitionInstructions =                                       // 2
    [self transitionInstructionsInVideoComposition:videoComposition];
    
    
    for (THTransitionInstructions *instructions in transitionInstructions) {
        
        CMTimeRange timeRange =                                             // 3
        instructions.compositionInstruction.timeRange;
        
        AVMutableVideoCompositionLayerInstruction *fromLayer =
        instructions.fromLayerInstruction;
        
        
        AVMutableVideoCompositionLayerInstruction *toLayer =
        instructions.toLayerInstruction;
        
        THVideoTransitionType type = instructions.transition.type;
        
        if (type == THVideoTransitionTypeDissolve) {
            
            [fromLayer setOpacityRampFromStartOpacity:1.0
                                         toEndOpacity:0.0
                                            timeRange:timeRange];
        }
        
        if (type == THVideoTransitionTypePush) {
            
            // Define starting and ending transforms                        // 1
            CGAffineTransform identityTransform = CGAffineTransformIdentity;
            
            CGFloat videoWidth = videoComposition.renderSize.width;
            
            CGAffineTransform fromDestTransform =                           // 2
            CGAffineTransformMakeTranslation(-videoWidth, 0.0);
            
            CGAffineTransform toStartTransform =
            CGAffineTransformMakeTranslation(videoWidth, 0.0);
            
            [fromLayer setTransformRampFromStartTransform:identityTransform // 3
                                           toEndTransform:fromDestTransform
                                                timeRange:timeRange];
            
            [toLayer setTransformRampFromStartTransform:toStartTransform    // 4
                                         toEndTransform:identityTransform
                                              timeRange:timeRange];
        }
        
        if (type == THVideoTransitionTypeWipe) {
            
            CGFloat videoWidth = videoComposition.renderSize.width;
            CGFloat videoHeight = videoComposition.renderSize.height;
            
            CGRect startRect = CGRectMake(0.0f, 0.0f, videoWidth, videoHeight);
            CGRect endRect = CGRectMake(0.0f, videoHeight, videoWidth, 0.0f);
            
            [fromLayer setCropRectangleRampFromStartCropRectangle:startRect
                                               toEndCropRectangle:endRect
                                                        timeRange:timeRange];
        }
        
        instructions.compositionInstruction.layerInstructions = @[fromLayer,// 4
                                                                  toLayer];
    }
    
    return videoComposition;
}

// Extract the composition and layer instructions out of the
// prebuilt AVVideoComposition. Make the association between the instructions
// and the THVideoTransition the user configured in the timeline.
- (NSArray *)transitionInstructionsInVideoComposition:(AVVideoComposition *)vc {
    
    NSMutableArray *transitionInstructions = [NSMutableArray array];
    
    int layerInstructionIndex = 1;
    
    NSArray *compositionInstructions = vc.instructions;                     // 1
    for (AVMutableVideoCompositionInstruction *vci in compositionInstructions) {
        
        if (vci.layerInstructions.count == 2) {                             // 2
            
            THTransitionInstructions *instructions =
            [[THTransitionInstructions alloc] init];
            
            instructions.compositionInstruction = vci;
            
            instructions.fromLayerInstruction =                             // 3
            (AVMutableVideoCompositionLayerInstruction *)vci.layerInstructions[1 - layerInstructionIndex];
            
            instructions.toLayerInstruction =
            (AVMutableVideoCompositionLayerInstruction *)vci.layerInstructions[layerInstructionIndex];
            
            [transitionInstructions addObject:instructions];
            
            layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1;
        }
    }
    
    NSArray *transitions = self.transitionLists;
    
    // Transitions are disabled
    if (transitions.count == 0) {                                           // 4
        return transitionInstructions;
    }
    
    NSAssert(transitionInstructions.count == transitions.count,
             @"Instruction count and transition count do not match.");
    
    for (NSUInteger i = 0; i < transitionInstructions.count; i++) {         // 5
        THTransitionInstructions *tis = transitionInstructions[i];
        tis.transition = self.transitionLists[i];
    }
    
    return transitionInstructions;
}


-(void)beginExport{
    self.exportSession = [self makeExportable];                 // 1
    self.exportSession.outputURL = [self exportURL];
    NSLog(@"%@", self.exportSession.outputURL);
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{        // 2
        
        dispatch_async(dispatch_get_main_queue(), ^{                        // 1
            AVAssetExportSessionStatus status = self.exportSession.status;
            if (status == AVAssetExportSessionStatusCompleted) {
                [self writeExportedVideoToAssetsLibrary];
            } else {
                
            }
        });
    }];
}
- (AVAssetExportSession *)makeExportable {                                  // 2
    NSString *preset = AVAssetExportPresetHighestQuality;
    return [AVAssetExportSession exportSessionWithAsset:[self.composition copy]
                                             presetName:preset];
}

- (AVPlayerItem *)makePlayable {                                            // 1
//    CMTime THDefaultFadeInOutTime = {3, 2, 1, 0}; // 1.5 seconds
    AVComposition *composition = [self.composition copy];
//    AVCompositionTrack *track = [composition trackWithTrackID:2];
//    CMTime twoSeconds = CMTimeMake(2, 1);
//    CMTime fourSeconds = CMTimeMake(4, 1);
//
//    AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
//    [parameters setVolume:0.2f atTime:kCMTimeZero];
//    CMTimeRange range = CMTimeRangeFromTimeToTime(twoSeconds, fourSeconds);
//    [parameters setVolumeRampFromStartVolume:0.2f toEndVolume:0.8f timeRange:range];
//    //long long int duration = track.timeRange.duration.value / track.timeRange.duration.timescale;得出秒数
//    CMTime endRangeStartTime = CMTimeSubtract(track.timeRange.duration, THDefaultFadeInOutTime);
//    CMTimeRange endRange = CMTimeRangeMake(endRangeStartTime, THDefaultFadeInOutTime);
//    [parameters setVolumeRampFromStartVolume:1.0f toEndVolume:0.0f timeRange:endRange];
//    
//    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
//    audioMix.inputParameters = @[parameters];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition];
//    playerItem.audioMix = audioMix;
    
    AVVideoComposition *videoCompositon = [self buildVideoComposition];
    playerItem.videoComposition = videoCompositon;
    return playerItem;
}
-(void)beginPlay{
    self.playSession = [self makePlayable];
    AVPlayer *avPlayer = [[AVPlayer alloc]initWithPlayerItem:self.playSession];
    AVPlayerViewController *playerCV = [[AVPlayerViewController alloc] init];
    playerCV.player = avPlayer;
    [self presentViewController:playerCV animated:true completion:^{
        [avPlayer play];
    }];
}

- (NSURL *)exportURL {                                                      // 5
    NSString *filePath = nil;
    NSUInteger count = 0;
    do {
        filePath = NSTemporaryDirectory();
        NSString *numberString = count > 0 ?
        [NSString stringWithFormat:@"-%li", (unsigned long) count] : @"";
        NSString *fileNameString =
        [NSString stringWithFormat:@"Masterpiece-%@.m4v", numberString];
        filePath = [filePath stringByAppendingPathComponent:fileNameString];
        count++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    return [NSURL fileURLWithPath:filePath];
}
- (void)writeExportedVideoToAssetsLibrary {
    NSURL *exportURL = self.exportSession.outputURL;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL]) {  // 3
        
        [library writeVideoAtPathToSavedPhotosAlbum:exportURL               // 4
                                    completionBlock:^(NSURL *assetURL,
                                                      NSError *error) {
                                        
                                        if (error) {                                                    // 5

                                        }
                                        
                                        [[NSFileManager defaultManager] removeItemAtURL:exportURL       // 6
                                                                                  error:nil];
                                    }];
    } else {
        NSLog(@"Video could not be exported to assets library.");
    }
    self.exportSession = nil;
}
- (IBAction)export {
    [self addTrack2Composition:self.videoReadyPools Type:AVMediaTypeVideo];
    //[self addTrack2Composition:self.audioReadyPools Type:AVMediaTypeAudio];
    [self beginPlay];
}

@end
