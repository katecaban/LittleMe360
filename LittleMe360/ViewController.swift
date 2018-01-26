//
//  ViewController.swift
//  LittleMe360
//
//  Created by Kate Caban on 1/23/18.
//  Copyright © 2018 com.kate.caban. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // FollowMe360 EveryMe360
    
    var resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureResultLabel()
        // start up the camera
        
        let captureSession = AVCaptureSession()
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
    }
    
    func configureResultLabel(){
        
        resultLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        
        resultLabel.center = self.view.center
        
        resultLabel.font = UIFont(name: "Helvetica", size: 14)
        
        resultLabel.textColor = UIColor(red: 0.039, green: 0.192, blue: 0.259, alpha: 1)
        
        resultLabel.lineBreakMode = .byWordWrapping
        
        resultLabel.numberOfLines = 2
        
        resultLabel.text = "Test"
        
        resultLabel.backgroundColor = .green
        
        resultLabel.textAlignment = .center
        
        resultLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(resultLabel)
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // print("Camera captured a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedReq, error) in
            
            // check the error
            
            print(finishedReq.results!)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

