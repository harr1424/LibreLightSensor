//
//  ContentView.swift
//  LibreLightSensor
//
//  Created by John Harrington on 9/3/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var videoStream = VideoStream()
    
    var body: some View {
        if (!videoStream.cameraAccess) {
            Text("This app requires authorization to access your camera in order to work correctly. You may grant this access from your device settings menu.")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
        } else {
            
            VStack {
                if (videoStream.session != nil) {
                    VideoPreviewHolder(runningSession: videoStream.session)
                        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ProgressView()
                }
            }
            Text(String(format: "%.0f  Lux", videoStream.luminosityReading))
                .font(.system(size: 50))
                .padding()
        }
    }
}


