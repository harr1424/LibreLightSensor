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
        if (videoStream.session != nil) {
            VStack {
                VideoPreviewHolder(runningSession: videoStream.session)
            }.frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            ProgressView()
        }
        Text(String(format: "%.2f Lux", videoStream.luminosityReading))
            .font(.largeTitle)
            .padding()
    }
}


