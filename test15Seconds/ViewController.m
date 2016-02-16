//
//  ViewController.m
//  test15Seconds
//
//  Created by Tommy on 2016-02-11.
//  Copyright © 2016 jxh. All rights reserved.
//

#import "ViewController.h"
#import "THVideoItem.h"
#import "THTimelineItemViewModel.h"
#import "VideoItemCell.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVCompositionTrack.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import "THAudioItem.h"

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
        THTimelineItemViewModel *model = [THTimelineItemViewModel modelWithTimelineItem:timelineItem];
        
        [self.videoReadyPools addObject:model];

    }else{
        THTimelineItemViewModel *model = [THTimelineItemViewModel modelWithTimelineItem:timelineItem];
        [self.audioReadyPools addObject:model];
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

    THTimelineItemViewModel *model = self.videoReadyPools[indexPath.row];
    cell.duration.text = [NSString stringWithFormat:@"%.2llds", model.timelineItem.timeRange.duration.value /60000];
    cell.fileName.text = model.timelineItem.filename;
    return cell;
}

-(void)setUpCellSize{
    CGFloat width = CGRectGetWidth(self.PoolCollectionView.frame);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.PoolCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(width / 3, width / 4);
}

-(void)addTrack2Composition:(NSArray *)items Type:(NSString *)type{
    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
    
    AVMutableCompositionTrack *compositionTrack =                       // 2
    [self.composition addMutableTrackWithMediaType:type preferredTrackID:trackID];
    // Set insert cursor to 0
    CMTime cursorTime = kCMTimeZero;                                    // 3
    
    for (THTimelineItemViewModel *item in items) {
        
        
        
        AVAssetTrack *assetTrack =                                      // 5
        [[item.timelineItem.asset tracksWithMediaType:type] firstObject];
        
        [compositionTrack insertTimeRange:item.timelineItem.timeRange                // 6
                                  ofTrack:assetTrack
                                   atTime:cursorTime
                                    error:nil];
        
        // Move cursor to next item time
        cursorTime = CMTimeAdd(cursorTime, item.timelineItem.timeRange.duration);    // 7
    }
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
    return [AVPlayerItem playerItemWithAsset:[self.composition copy]];
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
    [self addTrack2Composition:self.audioReadyPools Type:AVMediaTypeAudio];
    [self beginPlay];
}

@end
