//
//  THTimelineItemViewModel.m
//  test15Seconds
//
//  Created by Tommy on 2016-02-14.
//  Copyright © 2016 jxh. All rights reserved.
//

#import "THTimelineItemViewModel.h"
#import "THVideoItem.h"

@implementation THTimelineItemViewModel
+ (id)modelWithTimelineItem:(THVideoItem *)timelineItem {
    return [[self alloc] initWithTimelineItem:timelineItem];
}

- (id)initWithTimelineItem:(THVideoItem *)timelineItem {
    self = [super init];
    if (self) {
        _timelineItem = timelineItem;
        //CMTimeRange maxTimeRange = CMTimeRangeMake(kCMTimeZero, timelineItem.timeRange.duration);
        //_maxWidthInTimeline = THGetWidthForTimeRange(maxTimeRange, TIMELINE_WIDTH / TIMELINE_SECONDS);
    }
    return self;
}
@end
