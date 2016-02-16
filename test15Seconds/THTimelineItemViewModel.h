//
//  THTimelineItemViewModel.h
//  test15Seconds
//
//  Created by Tommy on 2016-02-14.
//  Copyright © 2016 jxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THVideoItem.h"

@interface THTimelineItemViewModel : NSObject
@property(strong, atomic)THVideoItem *timelineItem;
+ (id)modelWithTimelineItem:(THVideoItem *)timelineItem;
@end
