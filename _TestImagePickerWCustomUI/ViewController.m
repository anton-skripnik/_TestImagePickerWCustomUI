//
//  ViewController.m
//  _TestImagePickerWCustomUI
//
//  Created by Anton Skripnik on 3/29/16.
//  Copyright © 2016 Myself. All rights reserved.
//

#import "ViewController.h"

#define INTERVAL 0.25

@protocol PictureTaker <NSObject>

@property(nonatomic, assign)            UIImagePickerControllerSourceType sourceType;
@property(nonatomic, assign)            BOOL showsCameraControls;
@property(nullable, nonatomic, strong)  UIView* cameraOverlayView;

- (void)takePicture;

@end


@interface UIImagePickerController () <PictureTaker> @end

@interface MockPictureTaker: UIViewController<PictureTaker>

@property(nonatomic, assign)            UIImagePickerControllerSourceType sourceType;
@property(nonatomic, assign)            BOOL showsCameraControls;
@property(nullable, nonatomic, strong)  UIView* cameraOverlayView;

@end

@implementation MockPictureTaker

- (void)setCameraOverlayView:(UIView *)cameraOverlayView {
    if (cameraOverlayView != _cameraOverlayView) {
        [_cameraOverlayView removeFromSuperview];
        
        [self.view addSubview:cameraOverlayView];
        cameraOverlayView.frame = self.view.bounds;
        
        _cameraOverlayView = cameraOverlayView;
    }
}

- (void)takePicture {
    NSLog(@"Picture taken!");
}

@end


@interface ViewController ()

@property(nullable, nonatomic, strong)  UIViewController<PictureTaker>* pictureTaker;
@property(nullable, nonatomic, strong)  NSTimer* timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleOpenCameraButtonTapped:(UIButton *)sender {
    if (self.pictureTaker) {
        return;
    }
    
    self.pictureTaker = [self _pictureTaker];
    self.pictureTaker.cameraOverlayView = [self _configuredCameraOverlayView];
    self.pictureTaker.showsCameraControls = NO;
    self.pictureTaker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:self.pictureTaker animated:YES completion:nil];
}

- (nonnull UIView *)_configuredCameraOverlayView {
    UIView* baseView = [UIView new];
    
    UIButton* startMakingPhotosButton = [UIButton new];
    [startMakingPhotosButton setTitle:@"Start" forState:UIControlStateNormal];
    [startMakingPhotosButton setFrame:CGRectMake(10, 10, 200, 60)];
    [startMakingPhotosButton addTarget:self action:@selector(_handleStartMakingPhotosButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [baseView addSubview:startMakingPhotosButton];
    
    return baseView;
}

- (void)_handleStartMakingPhotosButtonTap:(UIButton *)sender {
    sender.enabled = NO;
    sender.alpha = 0.6f;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:INTERVAL target:self selector:@selector(_handleTimerTick:) userInfo:nil repeats:YES];
}

- (void)_handleTimerTick:(NSTimer *)t {
    [self.pictureTaker takePicture];
}

- (nonnull UIViewController<PictureTaker> *)_pictureTaker {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return [UIImagePickerController new];
    }
    else {
        return [MockPictureTaker new];
    }
}

@end

