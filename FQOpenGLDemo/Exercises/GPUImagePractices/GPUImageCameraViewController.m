//
//  GPUImageCameraViewController.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2021/2/5.
//  Copyright © 2021 fanqi. All rights reserved.
//

#import "GPUImageCameraViewController.h"
#import "GPUImage.h"
#import "MyGhostFilter.h"

@interface GPUImageCameraViewController () <GPUImageVideoCameraDelegate> {
    /*
     GPUImageVideoCamera *videoCamera;
     GPUImageOutput<GPUImageInput> *filter;
     GPUImagePicture *sourcePicture;

     GPUImageUIElement *uiElementInput;
     
     GPUImageFilterPipeline *pipeline;
     */
    
    GPUImageVideoCamera *_videoCamera;
}

@end

@implementation GPUImageCameraViewController

- (void)loadView {
    self.view = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnDoubleTapped)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    GPUImageFilter *filter = [[MyGhostFilter alloc] init];
    [_videoCamera addTarget:filter];
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    [filter addTarget:filterView];
    
    [_videoCamera startCameraCapture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:NO];
}

- (void)dealloc {
    [_videoCamera stopCameraCapture];
    [_videoCamera removeAllTargets];
}

- (void)selfOnDoubleTapped {
    [_videoCamera rotateCamera];
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

@end
