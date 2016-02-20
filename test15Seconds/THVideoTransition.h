//
//  THVideoTransition.h
//  test15Seconds
//
//  Created by beihaiSellshou on 2/20/16.
//  Copyright © 2016 jxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
typedef enum {
    THVideoTransitionTypeNone,
    THVideoTransitionTypeDissolve,
    THVideoTransitionTypePush,
    THVideoTransitionTypeWipe
} THVideoTransitionType;

typedef enum {
    THPushTransitionDirectionLeftToRight = 0,
    THPushTransitionDirectionRightToLeft,
    THPushTransitionDirectionTopToButton,
    THPushTransitionDirectionBottomToTop,
    THPushTransitionDirectionInvalid = INT_MAX} THPushTransitionDirection;

@interface THVideoTransition : NSObject
+ (id)videoTransition;

@property (nonatomic) THVideoTransitionType type;
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CMTime duration;
@property (nonatomic) THPushTransitionDirection direction;

#pragma mark - Convenience initializers for stock transitions

+ (id)disolveTransitionWithDuration:(CMTime)duration;

+ (id)pushTransitionWithDuration:(CMTime)duration direction:(THPushTransitionDirection)direction;
@end
