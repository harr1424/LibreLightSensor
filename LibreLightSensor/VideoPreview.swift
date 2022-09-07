//
//  VideoPreview.swift
//  LibreLightSensor
//
//  Created by user on 9/7/22.
//

import SwiftUI
import UIKit
import AVFoundation


/*
 Used to display a video preview layer.
 */
class VideoPreview: UIView {
    private var session: AVCaptureSession!
    
    init(runningSession session: AVCaptureSession) {
        super.init(frame: .zero)
        self.session = session
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if self.superview != nil {
            self.videoPreviewLayer.session = self.session
            self.videoPreviewLayer.videoGravity = .resizeAspect
        }
    }
}

struct VideoPreviewHolder: UIViewRepresentable {
    public var runningSession: AVCaptureSession
    
    typealias UIViewType = VideoPreview
    
    func makeUIView(context: Context) -> VideoPreview {
        VideoPreview(runningSession: runningSession)
    }
    
    func updateUIView(_ uiView: VideoPreview, context: Context) {
        
    }
}
