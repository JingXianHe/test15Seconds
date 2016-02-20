//
//  THVideoTransition.m
//  test15Seconds
//
//  Created by beihaiSellshou on 2/20/16.
//  Copyright © 2016 jxh. All rights reserved.
//

#import "THVideoTransition.h"

@implementation THVideoTransition
+ (id)videoTransition {
    return [[[self class] alloc] init];
}

+ (id)disolveTransitionWithDuration:(CMTime)duration {
    THVideoTransition *transition = [self videoTransition];
    transition.type = THVideoTransitionTypeDissolve;
    transition.duration = duration;
    return transition;
}

+ (id)pushTransitionWithDuration:(CMTime)duration direction:(THPushTransitionDirection)direction {
    THVideoTransition *transition = [self videoTransition];
    transition.type = THVideoTransitionTypePush;
    transition.duration = duration;
    transition.direction = direction;
    return transition;
}


- (id)init {
    self = [super init];
    if (self) {
        _type = THVideoTransitionTypeDissolve;
        _timeRange = kCMTimeRangeInvalid;
    }
    return self;
}

- (void)setDirection:(THPushTransitionDirection)direction {
    if (self.type == THVideoTransitionTypePush) {
        _direction = direction;
    } else {
        _direction = THPushTransitionDirectionInvalid;
        NSAssert(NO, @"Direction can only be specified for a type == THVideoTransitionTypePush.");
    }
}

@end
