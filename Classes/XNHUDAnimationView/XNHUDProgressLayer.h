//
//  XNHUDProgressLayer.h
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "XNHUDLayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XNHUDProgressLayer : CALayer <XNHUDLayerProtocol>
@property (nonatomic, assign) CGFloat progress;
@end

NS_ASSUME_NONNULL_END
