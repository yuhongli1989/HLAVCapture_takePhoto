//
//  HLCapturePhtotOutput.swift
//  AVCaptureDemo_Swift
//
//  Created by yunfu on 2019/3/1.
//  Copyright © 2019 yunfu. All rights reserved.
//

import UIKit
import AVFoundation

protocol HLTakePhotoDelegate:NSObjectProtocol {
    func takePhoto(photoData:Data)
}

class HLCapturePhtotOutput: NSObject,AVCapturePhotoCaptureDelegate {
    
    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use AVCapturePhotoOutput instead.")
    lazy var imageOutput:AVCaptureStillImageOutput = {
        let output = AVCaptureStillImageOutput()
        output.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        return output
    }()
    
    @available(iOS 10.0, *)
    lazy var photoOutput:AVCapturePhotoOutput = {
        let photo = AVCapturePhotoOutput()
        return photo
    }()
    //拍照回调 照片数据
    var imageData:((Data)->Void)?
    
    func takePhoto()  {
        if #available(iOS 10.0, *) {
            let photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
            
            photoSettings.flashMode = .auto
            photoSettings.isAutoStillImageStabilizationEnabled =
                self.photoOutput.isStillImageStabilizationSupported
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
            
        }else{
            
            if let connection = self.imageOutput.connection(with: .video){
                if connection.isVideoOrientationSupported{
                    connection.videoOrientation = currentVideoOrientation
                }
                self.imageOutput.captureStillImageAsynchronously(from: connection) { [weak self] (sampleBuffer, error) in
                    guard let buffer = sampleBuffer,let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer) else{return}
                    self?.imageData?(data)
                }
            }
            
            
        }
    }
    
    private var currentVideoOrientation:AVCaptureVideoOrientation{
        let orientation:AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
            break
        case .landscapeRight:
            orientation = .landscapeLeft
            break
        case .portraitUpsideDown:
            orientation = .portraitUpsideDown
            break
        default:
            orientation = .landscapeRight
        }
        return orientation
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        imageData?(data)
    }
    @available(iOS, introduced: 10.0, deprecated: 11.0, message: "Use -captureOutput:didFinishProcessingPhoto:error: instead.")
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){
        guard let buffer = photoSampleBuffer,let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer) else{return}
        self.imageData?(data)
        
    }

}

extension AVCaptureSession{
    func canAdd(_ photoOutput:HLCapturePhtotOutput) -> Bool {
        if #available(iOS 10.0, *) {
            return self.canAddOutput(photoOutput.photoOutput)
        }else{
            return self.canAddOutput(photoOutput.imageOutput)
        }
    }
    
    func add(_ photoOutput:HLCapturePhtotOutput) {
        if #available(iOS 10.0, *) {
            self.addOutput(photoOutput.photoOutput)
        }else{
            self.addOutput(photoOutput.imageOutput)
        }
    }
    
    func remove(_ photoOutput:HLCapturePhtotOutput)  {
        if #available(iOS 10.0, *) {
            self.removeOutput(photoOutput.photoOutput)
        }else{
            self.removeOutput(photoOutput.imageOutput)
        }
    }
}
