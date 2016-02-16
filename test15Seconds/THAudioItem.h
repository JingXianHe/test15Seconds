//
//  THAudioItem.h
//  test15Seconds
//
//  Created by beihaiSellshou on 2/16/16.
//  Copyright © 2016 jxh. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
typedef void(^THPreparationCompletionBlock)(BOOL complete);

@interface THAudioItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *filename;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) AVAsset *asset;
@property (nonatomic, readonly) BOOL prepared;
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CMTime startTimeInTimeline;
+ (id)audioItemWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;
- (void)prepareWithCompletionBlock:(THPreparationCompletionBlock)completionBlock;
@end
