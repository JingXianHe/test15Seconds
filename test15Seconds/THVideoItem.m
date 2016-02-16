//
//  THVideoItem.m
//  test15Seconds
//
//  Created by Tommy on 2016-02-12.
//  Copyright © 2016 jxh. All rights reserved.
//

#import "THVideoItem.h"
#import <UIKit/UIKit.h>

@implementation THVideoItem
+ (id)videoItemWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        _filename = [[url lastPathComponent] copy];
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
        _asset = [AVURLAsset URLAssetWithURL:url options:options];
    }
    if (self) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        _imageGenerator.maximumSize = THUMBNAIL_SIZE;
        _thumbnails = @[];
        _images = [NSMutableArray arrayWithCapacity:THUMBNAIL_COUNT];
    }
    return self;
}
- (void)prepareWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
    [self.asset loadValuesAsynchronouslyForKeys:@[AVAssetTracksKey, AVAssetDurationKey, AVAssetCommonMetadataKey] completionHandler:^{
        // Production code should be more robust.  Specifically, should capture error in failure case.
        AVKeyValueStatus tracksStatus = [self.asset statusOfValueForKey:AVAssetTracksKey error:nil];
        AVKeyValueStatus durationStatus = [self.asset statusOfValueForKey:AVAssetDurationKey error:nil];
        _prepared = (tracksStatus == AVKeyValueStatusLoaded) && (durationStatus == AVKeyValueStatusLoaded);
        if (self.prepared) {
            self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
            [self performPostPrepareActionsWithCompletionBlock:completionBlock];
        } else {
            if (completionBlock) {
                completionBlock(NO);
            }
        }
    }];
}
- (void)performPostPrepareActionsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self generateThumbnailsWithCompletionBlock:completionBlock];
    });
}

- (void)generateThumbnailsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
    
    CMTime duration = self.asset.duration;
    CMTimeValue intervalSeconds = duration.value / THUMBNAIL_COUNT;
    
    CMTime time = kCMTimeZero;
    NSMutableArray *times = [NSMutableArray array];
    for (NSUInteger i = 0; i < THUMBNAIL_COUNT; i++) {
        [times addObject:[NSValue valueWithCMTime:time]];
        time = CMTimeAdd(time, CMTimeMake(intervalSeconds, duration.timescale));
    }
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime,
                                                                                          CGImageRef cgImage,
                                                                                          CMTime actualTime,
                                                                                          AVAssetImageGeneratorResult result,
                                                                                          NSError *error) {
        
        if (cgImage) {
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            [self.images addObject:image];
            
        } else {
            [self.images addObject:[UIImage imageNamed:@"video_thumbnail"]];
        }
        
        if (self.images.count == THUMBNAIL_COUNT) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.thumbnails = [NSArray arrayWithArray:self.images];
                completionBlock(YES);
            });
        }
    }];
}

@end
