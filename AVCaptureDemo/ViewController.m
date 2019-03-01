//
//  ViewController.m
//  AVCaptureDemo
//
//  Created by yunfu on 2019/2/28.
//  Copyright © 2019 yunfu. All rights reserved.
//

#import "ViewController.h"
#import "HLCapture/HLCapture.h"
@interface ViewController ()<HLTakePhotoDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController
{
    HLCapture *capture;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    capture = [[HLCapture alloc] initWithType:HLCaptureTypeVideo];
    [capture prepareWithSize:self.view.frame.size];
    capture.takePhotoDelegate = self;
    [self.view addSubview:capture.videoView];
    
    [self.view sendSubviewToBack:capture.videoView];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [capture startCapture];
}

- (IBAction)takeClick:(id)sender {
    [capture takePhoto];
}


- (void)takePhoto:(NSData *)imageData{
    self.imageView.image = [[UIImage alloc] initWithData:imageData];
}
- (IBAction)flashClick:(id)sender {
    [capture openAndCloseTorch];
}
- (IBAction)switchCamera:(id)sender {
    [capture switchCameras];
}


@end
