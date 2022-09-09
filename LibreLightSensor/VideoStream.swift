//
//  VideoStream.swift
//  LibreLightSensor
//
//  Created by user on 9/7/22.
//

import Foundation
import AVKit


/*
 This class is responsible for configuring an AVCaptureSession in order to calculate brightness.
 */
class VideoStream: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var luminosityReading : Double = 0.0
    @Published var cameraAccess = false
    
    public var session : AVCaptureSession!
    var configureAVCaptureSessionQueue = DispatchQueue(label: "ConfigureAVCaptureSessionQueue")
    
    override init() {
        super.init()
        configureAVCaptureSessionQueue.async {
           self.authorizeCapture() // this needs to be awaited
        }
    }
    
    /*
     Determine authroization status and request authorization if necessary.
     */
    func authorizeCapture()  {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            DispatchQueue.main.async {
                self.cameraAccess = true
            }
            beginCapture()
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.cameraAccess = true
                    }
                    self.beginCapture()
                }
            }
            
        default:
            return
        }
    }
    
    /*
     Find best device and add it as input, establish output and set its sample buffer delegate
     in order to call captureOutput and calculate brightness in lux.
     */
    func beginCapture() {
        
        session = AVCaptureSession()
        session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(for: .video)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            session.canAddInput(videoDeviceInput)
        else {
            print("Camera selection failed")
            return
        }
        session.addInput(videoDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        guard
            session.canAddOutput(videoOutput)
        else {
            print("Error creating video output")
            return
        }
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "CaptureOutputQueue"))
        session.addOutput(videoOutput)
        
        session.sessionPreset = .medium
        session.commitConfiguration()
        session.startRunning()
    }
    
    // Calculate brightness in lux
    // From: https://stackoverflow.com/questions/41921326/how-to-get-light-value-from-avfoundation/46842115#46842115
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        
        let FNumber : Double = exifData?["FNumber"] as! Double
        let ExposureTime : Double = exifData?["ExposureTime"] as! Double
        let ISOSpeedRatingsArray = exifData!["ISOSpeedRatings"] as? NSArray
        let ISOSpeedRatings : Double = ISOSpeedRatingsArray![0] as! Double
        let CalibrationConstant : Double = 50
        
        let luminosity : Double = (CalibrationConstant * FNumber * FNumber ) / ( ExposureTime * ISOSpeedRatings )
        DispatchQueue.main.async {
            self.luminosityReading = luminosity
        }
    }
}

