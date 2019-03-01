//
//  HLCaptureView.m
//  AVCaptureDemo
//
//  Created by yunfu on 2019/2/28.
//  Copyright © 2019 yunfu. All rights reserved.
//

#import "HLCaptureView.h"

@implementation HLCaptureView


- (void)setSession:(AVCaptureSession *)session{
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
    _session = session;
}


+ (Class)layerClass{
    return [AVCaptureVideoPreviewLayer class];
}

@end
