//
//  ContentView.swift
//  LibreLightSensor
//
//  Created by John Harrington on 9/3/22.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var videoStream = VideoStream()
    
    var body: some View {
        Text(String(format: "%.2f Lux", videoStream.luminosityReading))
            .padding()
    }
}

/*
 THis class is responsible for requesting permission to access user device camera and begin a AVCaptureSession.
 */
class VideoStream: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var luminosityReading : Double = 0.0
    
    var session : AVCaptureSession!
        
    override init() {
        super.init()
        authorizeCapture()
    }
    
    /*
     Determine authroization status and request authorization if necessary.
     */
    func authorizeCapture() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            beginCapture()
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.beginCapture()
                }
            }
            
        case .denied: // The user has previously denied access.
            return
            
        case .restricted: // The user can't grant access due to restrictions.
            return
        }
    }
    
    /*
     Determine the best camera on the device to use for an AVCapture session,
     (considering only the cameras used for environment photos as opposed to 'self' photos),
     use this device for an AVInput, and establish an AVOutput.
     
     Establish the required delegate to implement the captureOutput function as found on StackOverflow.
     This function will determine the luminosity / brightness.
     */
    func beginCapture() {
        
        print("beginCapture entered")
        
        func bestDevice() -> AVCaptureDevice {
            let devices = discoverySession.devices
            guard !devices.isEmpty else { fatalError("Missing capture devices.")}
            
            return devices.first(where: { device in device.position == AVCaptureDevice.Position.back })!
        }
        
        
        session = AVCaptureSession()
        session.beginConfiguration()
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
                                                                    [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                                mediaType: .video, position: .back)
        
        let videoDevice = bestDevice()
        print("Device: \(videoDevice)")
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            session.canAddInput(videoDeviceInput)
        else {
            print("Camera selection failed")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        guard
            session.canAddOutput(videoOutput)
        else {
            print("Error creating video output")
            return
        }
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        session.addOutput(videoOutput)
        
        session.sessionPreset = .medium
        session.commitConfiguration()
        session.startRunning()
    }
    
    
    // From: https://stackoverflow.com/questions/41921326/how-to-get-light-value-from-avfoundation/46842115#46842115
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        print("captureOutput entered")  // never printed
        
        // Retrieving EXIF data of camara frame buffer
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        
        let FNumber : Double = exifData?["FNumber"] as! Double
        let ExposureTime : Double = exifData?["ExposureTime"] as! Double
        let ISOSpeedRatingsArray = exifData!["ISOSpeedRatings"] as? NSArray
        let ISOSpeedRatings : Double = ISOSpeedRatingsArray![0] as! Double
        let CalibrationConstant : Double = 50
        
        //Calculating the luminosity
        let luminosity : Double = (CalibrationConstant * FNumber * FNumber ) / ( ExposureTime * ISOSpeedRatings )
        luminosityReading = luminosity
    }
}







