//
//  HLCaptureManager.swift
//  AVCaptureDemo_Swift
//
//  Created by yunfu on 2019/3/1.
//  Copyright © 2019 yunfu. All rights reserved.
//

import UIKit
import AVFoundation

struct HLCaptureType:OptionSet {
    public let rawValue: UInt
    public static var audio: HLCaptureType { return HLCaptureType(rawValue: 0x01)  }
    public static var video: HLCaptureType { return HLCaptureType(rawValue: 0x02)  }
    public static var all:HLCaptureType = [HLCaptureType.audio,HLCaptureType.video]
}


class HLCaptureManager: NSObject {
    
    public weak var takePhotoDelegate:HLTakePhotoDelegate?
    //前置摄像头
    
    public lazy var frontCamera:AVCaptureDevice? = {
        if #available(iOS 10.0, *){
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }else{
            let devices = AVCaptureDevice.devices(for: .video)
            for device in devices{
                if device.position == AVCaptureDevice.Position.front{
                    return device
                }
            }
        }
       return nil
        
    }()
    //后置摄像头
    public lazy var backCamera:AVCaptureDevice? = {
        if #available(iOS 10.0, *){
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }else{
            let devices = AVCaptureDevice.devices(for: .video)
            for device in devices{
                if device.position == AVCaptureDevice.Position.back{
                    return device
                }
            }
        }
        return nil
    }()
    //正在使用的摄像头
    public lazy var activeCamera:AVCaptureDevice? = {
        return AVCaptureDevice.default(for: .video)
    }()

    public lazy var session:AVCaptureSession = AVCaptureSession()
    
    private(set) var type:HLCaptureType
    
    lazy var captureInput:AVCaptureDeviceInput? = {
        guard let device = self.activeCamera else{return nil}
        return try? AVCaptureDeviceInput(device: device)
    }()
    
    lazy var photoOutput:HLCapturePhtotOutput = HLCapturePhtotOutput()
    
    init(_ type:HLCaptureType) {
        self.type = type
    }
    
    func prepare()  {
        if type.rawValue & 0x01 > 0  {
            setupAudio()
        }
        
        if type.rawValue & 0x02 > 0 {
            self.setupVideo()
        }
        photoOutput.imageData = { [weak self] (data) in
            self?.takePhotoDelegate?.takePhoto(photoData: data)
        }
    }
    
    func setupVideo()  {
        self.session.beginConfiguration()
        if let input = self.captureInput, self.session.canAddInput(input) {
            self.session.addInput(input)
        }
        
        if session.canAdd(photoOutput) {
            session.add(photoOutput)
        }
        self.session.commitConfiguration()
    }
    
    public func take(){
        
        photoOutput.takePhoto()
        
    }
    
    func setupAudio()  {
        
    }
    
    public func startRunning(){
        DispatchQueue.global().async {
            if !self.session.isRunning{
                self.session.startRunning()
            }
            
        }
    }
    
    public func stopRunning(){
        DispatchQueue.global().async {
            if self.session.isRunning{
                self.session.stopRunning()
            }
            
        }
    }
    
    public func switchCameras(){
        guard let defaultInput = captureInput else {
            return
        }
        
        if self.activeCamera?.position == AVCaptureDevice.Position.back {
            
            if let camera = self.frontCamera,let frontInput = try? AVCaptureDeviceInput(device: camera){
                self.session.beginConfiguration()
                
                self.session.removeInput(defaultInput)
                if self.session.canAddInput(frontInput){
                    self.session.addInput(frontInput)
                    self.activeCamera = camera
                    self.captureInput = frontInput
                }else{
                    self.session.addInput(defaultInput)
                    
                }
                self.session.commitConfiguration()
            }
            
            
        }else if self.activeCamera?.position == AVCaptureDevice.Position.front{
            if let camera = self.backCamera,let backInput = try? AVCaptureDeviceInput(device: camera){
                self.session.beginConfiguration()
                
                self.session.removeInput(defaultInput)
                if self.session.canAddInput(backInput){
                    self.session.addInput(backInput)
                    self.activeCamera = camera
                    self.captureInput = backInput
                }else{
                    self.session.addInput(defaultInput)
                }
                self.session.commitConfiguration()
            }
        }
    }
    
    public func openAndCloseTorch()  {
        guard let camera = self.activeCamera else {
            return
        }
        if camera.torchMode == AVCaptureDevice.TorchMode.off {
            setUpMode(.on)
        }else if camera.torchMode == AVCaptureDevice.TorchMode.on{
            setUpMode(.off)
        }
    }
    
    func setUpMode(_ mode:AVCaptureDevice.TorchMode)  {
        guard let camera = self.activeCamera else{return}
        if  camera.hasTorch ,camera.isTorchModeSupported(mode){
            do{
                try camera.lockForConfiguration()
                camera.torchMode = mode
                camera.unlockForConfiguration()
            }catch{
                
            }
        }
    }
    
    deinit {
        self.session.stopRunning()
        self.setUpMode(.off)
        self.removeVideo()
        
    }
    
    
    func removeVideo()  {
        self.session.beginConfiguration()
        if let input = self.captureInput{
            self.session.removeInput(input)
        }
        self.session.remove(self.photoOutput)
        self.session.commitConfiguration()
    }
    
}
