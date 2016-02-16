//
//  THVideoItem.h
//  test15Seconds
//
//  Created by Tommy on 2016-02-12.
//  Copyright © 2016 jxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#define THUMBNAIL_COUNT 4
#define THUMBNAIL_SIZE CGSizeMake(227.0f, 128.0f)
typedef void(^THPreparationCompletionBlock)(BOOL complete);
static NSString *const AVAssetTracksKey = @"tracks";
static NSString *const AVAssetDurationKey = @"duration";
static NSString *const AVAssetCommonMetadataKey = @"commonMetadata";

@interface THVideoItem : NSObject
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *filename;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSArray *thumbnails;
@property (nonatomic, readonly) BOOL prepared;
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CMTime startTimeInTimeline;

+ (id)videoItemWithURL:(NSURL *)url;
- (void)prepareWithCompletionBlock:(THPreparationCompletionBlock)completionBlock;
@end
