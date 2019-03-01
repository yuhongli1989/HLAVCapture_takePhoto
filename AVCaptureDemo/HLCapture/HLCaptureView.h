//
//  HLCaptureView.h
//  AVCaptureDemo
//
//  Created by yunfu on 2019/2/28.
//  Copyright © 2019 yunfu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLCaptureView : UIView

@property (nonatomic, strong)AVCaptureSession *session;

@end

NS_ASSUME_NONNULL_END
