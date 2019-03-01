//
//  HLCapture.h
//  AVCaptureDemo
//
//  Created by yunfu on 2019/2/28.
//  Copyright © 2019 yunfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "HLCaptureView.h"

@protocol HLTakePhotoDelegate <NSObject>

- (void)takePhoto:(NSData *)imageData;

@end

/*
 媒体捕捉类型
 */
typedef NS_OPTIONS(NSUInteger, HLCaptureType) {
    HLCaptureTypeAudio = 1 << 0,
    HLCaptureTypeVideo = 1 << 1
};

NS_ASSUME_NONNULL_BEGIN

@interface HLCapture : NSObject
@property (nonatomic, weak)id<HLTakePhotoDelegate> takePhotoDelegate;
@property (nonatomic,assign)HLCaptureType type;
//预览图
@property (nonatomic,strong)HLCaptureView *videoView;

- (instancetype)initWithType:(HLCaptureType)type;
- (void)prepareWithSize:(CGSize)size;
- (void)startCapture;
- (void)stopCapture;
- (void)switchCameras;
- (void)openAndCloseFlash;
- (void)takePhoto;
@end

NS_ASSUME_NONNULL_END
