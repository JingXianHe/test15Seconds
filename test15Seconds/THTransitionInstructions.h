//
//  THTransitionInstructions.h
//  test15Seconds
//
//  Created by beihaiSellshou on 2/20/16.
//  Copyright © 2016 jxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "THVideoTransition.h"

@interface THTransitionInstructions : NSObject
@property (strong, nonatomic) AVMutableVideoCompositionInstruction *compositionInstruction;
@property (strong, nonatomic) AVMutableVideoCompositionLayerInstruction *fromLayerInstruction;
@property (strong, nonatomic) AVMutableVideoCompositionLayerInstruction *toLayerInstruction;
@property (strong, nonatomic) THVideoTransition *transition;
@end
