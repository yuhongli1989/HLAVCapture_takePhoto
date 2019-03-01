//
//  HLCapture.m
//  AVCaptureDemo
//
//  Created by yunfu on 2019/2/28.
//  Copyright © 2019 yunfu. All rights reserved.
//

#import "HLCapture.h"


@interface HLCapture () <AVCapturePhotoCaptureDelegate>



//捕捉会话
@property (nonatomic,strong)AVCaptureSession *session;

@property (nonatomic, strong)AVCaptureDeviceInput *captureInput;
//正在使用的摄像机
@property (nonatomic, strong)AVCaptureDevice *activityCamera;
//后摄像头
@property (nonatomic, strong)AVCaptureDevice *backgroundCamera;
//前摄像头
@property (nonatomic, strong)AVCaptureDevice *frontCamera;

///iOS 10 以前拍照输出
@property (nonatomic, strong)AVCaptureStillImageOutput *imageOutput;
///iOS 10 以后拍照输出
@property (nonatomic, strong)AVCapturePhotoOutput *photoOutput API_AVAILABLE(ios(10.0));

@end

@implementation HLCapture
{
    //摄像头方向
    BOOL isBack;
    dispatch_queue_t dataOutputQueue;
}

- (instancetype)initWithType:(HLCaptureType)type
{
    self = [super init];
    if (self) {
        self.type = type;
        isBack = YES;
        dataOutputQueue = dispatch_queue_create("dataOutputQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

//懒加载
- (AVCaptureSession *)session{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureDevice *)backgroundCamera{
    if (!_backgroundCamera) {
        if (@available(iOS 10.0, *)) {
            _backgroundCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        } else {
            NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            for (AVCaptureDevice *device in devices) {
                if (device.position == AVCaptureDevicePositionBack) {
                    _backgroundCamera = device;
                }
            }
        }
    }
    return _backgroundCamera;
}

- (AVCaptureDevice *)fontCamera{
    if (!_frontCamera) {
        if (@available(iOS 10.0, *)) {
            _frontCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        } else {
            NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            for (AVCaptureDevice *device in devices) {
                if (device.position == AVCaptureDevicePositionFront) {
                    _frontCamera = device;
                }
            }
        }
    }
    return _frontCamera;
}

- (AVCaptureDevice *)activityCamera{
    if (!_activityCamera) {
        _activityCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        isBack = _activityCamera.position == AVCaptureDevicePositionBack;
    }
    return _activityCamera;
}

- (AVCapturePhotoOutput *)photoOutput API_AVAILABLE(ios(10.0)){
    if (!_photoOutput) {
        _photoOutput = [[AVCapturePhotoOutput alloc] init];
        
        
        
    }
    return _photoOutput;
}

- (HLCaptureView *)videoView{
    if (!_videoView) {
        _videoView = [[HLCaptureView alloc] init];
    }
    return _videoView;
}

- (void)prepareWithSize:(CGSize)size{
    
    self.videoView.session = self.session;
    _videoView.frame = CGRectMake(0, 0, size.width, size.height);
    
    if (_type&0X01) {
        [self setupAudio];
    }
    if (_type&0x02) {
        [self setupVideo];
    }

}

- (AVCaptureStillImageOutput *)imageOutput{
    if (!_imageOutput) {
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        _imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    }
    return _imageOutput;
}

- (void)setupAudio{
    
}


- (void)setupVideo{
    _captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.activityCamera error:nil];
    
    [_session beginConfiguration];
    if ([self.session canAddInput:_captureInput]) {
        [self.session addInput:_captureInput];
    }
    
    if (@available(iOS 10.0, *)) {
        if ([self.session canAddOutput:self.photoOutput]) {
            [self.session addOutput:self.photoOutput];
        }
    } else {
        if ([self.session canAddOutput:self.imageOutput]){
            [self.session addOutput:self.imageOutput];
        }
    }
    [_session commitConfiguration];
    
}

- (void)startCapture{
    
    if (![self.session isRunning]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session startRunning];
        });
    }
    
}

- (void)stopCapture{
    if ([self.session isRunning]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session stopRunning];
        });
    }
}

- (void)switchCameras{
    
    if (self.activityCamera.position == AVCaptureDevicePositionBack) {
        
        if (self.fontCamera) {
            [self.session beginConfiguration];
            [self.session removeInput:self.captureInput];
            AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.fontCamera error:nil];
            if ([self.session canAddInput:input]) {
                [self.session addInput:input];
                self.activityCamera = self.fontCamera;
                self.captureInput = input;
            }else{
                [self.session addInput:self.captureInput];
            }
            [self.session commitConfiguration];
        }
        
    }else{
        if (self.backgroundCamera) {
            [self.session beginConfiguration];
            [self.session removeInput:self.captureInput];
            AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.backgroundCamera error:nil];
            if ([self.session canAddInput:input]) {
                [self.session addInput:input];
                self.activityCamera = self.backgroundCamera;
                self.captureInput = input;
            }else{
                [self.session addInput:self.captureInput];
            }
            
            [self.session commitConfiguration];
        }
    }
    isBack = _activityCamera.position == AVCaptureDevicePositionBack;
}




- (void)takePhoto{
    if (@available(iOS 10.0, *)){
        
        
        [self.photoOutput capturePhotoWithSettings:[AVCapturePhotoSettings photoSettings] delegate:self];
        
    }else{
        AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
        //设置捕获方向
        if (connection.isVideoOrientationSupported) {
            connection.videoOrientation = [self currentVideoOrientation];
        }
        __weak typeof(self) weakSelf = self;
        [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
            
            if (imageDataSampleBuffer != NULL) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                if ([weakSelf.takePhotoDelegate respondsToSelector:@selector(takePhoto:)]) {
                    [weakSelf.takePhotoDelegate takePhoto:imageData];
                }
                
            }
        }];
    }
    
}

- (AVCaptureVideoOrientation)currentVideoOrientation {
    
    AVCaptureVideoOrientation orientation;
    
    switch ([UIDevice currentDevice].orientation) {                         // 3
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    
    return orientation;
}

- (void)openAndCloseTorch{
    AVCaptureTorchMode mode = self.backgroundCamera.torchMode;
    
    if (mode != AVCaptureTorchModeOff) {
        [self setTorchMode:AVCaptureTorchModeOff];
    }else{
        [self setTorchMode:AVCaptureTorchModeOn];
    }
}

- (void)setTorchMode:(AVCaptureTorchMode)flashMode{
    if ([self.backgroundCamera hasTorch]) {
        
        if ([self.backgroundCamera isTorchModeSupported:flashMode]){
            
            if ([self.backgroundCamera lockForConfiguration:nil]) {
                
                self.backgroundCamera.torchMode = flashMode;
                [self.backgroundCamera unlockForConfiguration];
            }
        }
        
    }
}

- (void)removeVideo{
    [self.session commitConfiguration];
    [self.session removeInput:self.captureInput];
    if (@available(iOS 10.0,*)) {
        [self.session removeOutput:self.photoOutput];
    }else{
        [self.session removeOutput:self.imageOutput];
    }
    [self.session commitConfiguration];
}

- (void)dealloc
{
    [self.session stopRunning];
    [self setFlashMode:AVCaptureTorchModeOn];
    [self removeVideo];
    
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error API_AVAILABLE(ios(11.0)){
    NSLog(@"%s",__func__);
    if ([self.takePhotoDelegate respondsToSelector:@selector(takePhoto:)]) {
        [_takePhotoDelegate takePhoto:photo.fileDataRepresentation];
    }
    

}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error API_DEPRECATED("Use -captureOutput:didFinishProcessingPhoto:error: instead.", ios(10.0, 11.0)){
    NSLog(@"%s",__func__);
    if (photoSampleBuffer != NULL) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:photoSampleBuffer];
        if ([self.takePhotoDelegate respondsToSelector:@selector(takePhoto:)]) {
            [self.takePhotoDelegate takePhoto:imageData];
        }
        
    }
}


@end
