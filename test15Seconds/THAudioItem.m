//
//  THAudioItem.m
//  test15Seconds
//
//  Created by beihaiSellshou on 2/16/16.
//  Copyright © 2016 jxh. All rights reserved.
//

#import "THAudioItem.h"

@implementation THAudioItem

+ (id)audioItemWithURL:(NSURL *)url {
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
    return self;
}

- (NSString *)mediaType {
    return AVMediaTypeAudio;
}

- (void)prepareWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
    [self.asset loadValuesAsynchronouslyForKeys:@[@"tracks", @"duration", @"commonMetadata"] completionHandler:^{
        // Production code should be more robust.  Specifically, should capture error in failure case.
        AVKeyValueStatus tracksStatus = [self.asset statusOfValueForKey:@"tracks" error:nil];
        AVKeyValueStatus durationStatus = [self.asset statusOfValueForKey:@"duration" error:nil];
        _prepared = (tracksStatus == AVKeyValueStatusLoaded) && (durationStatus == AVKeyValueStatusLoaded);
        if (self.prepared) {
            self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
        } else {
            if (completionBlock) {
                completionBlock(NO);
            }
        }
    }];
}

@end
