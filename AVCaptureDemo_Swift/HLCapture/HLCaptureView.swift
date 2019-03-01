//
//  HLCaptureView.swift
//  AVCaptureDemo_Swift
//
//  Created by yunfu on 2019/3/1.
//  Copyright © 2019 yunfu. All rights reserved.
//

import UIKit
import AVFoundation

class HLCaptureView: UIView {

    override open class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    public var session:AVCaptureSession?{
        didSet{
            (self.layer as! AVCaptureVideoPreviewLayer).session = session
        }
    }
    

}
