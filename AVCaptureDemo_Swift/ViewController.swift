//
//  ViewController.swift
//  AVCaptureDemo_Swift
//
//  Created by yunfu on 2019/3/1.
//  Copyright © 2019 yunfu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,HLTakePhotoDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let captureManager = HLCaptureManager(.video)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let preView = HLCaptureView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(preView)
        captureManager.prepare()
        preView.session = captureManager.session
        captureManager.takePhotoDelegate = self
        self.view.sendSubviewToBack(preView)
        captureManager.startRunning()
    }
    
    func takePhoto(photoData: Data) {
        self.imageView.image = UIImage(data: photoData)
    }


    
    @IBAction func takePhoto(_ sender: Any) {
        captureManager.take()
    }
    
    @IBAction func torchClick(_ sender: Any) {
        captureManager.openAndCloseTorch()
    }
    
    @IBAction func switchClick(_ sender: Any) {
        captureManager.switchCameras()
    }
}

