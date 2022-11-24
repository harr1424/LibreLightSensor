//
//  ContentView.swift
//  LibreLightSensor
//
//  Created by John Harrington on 9/3/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var videoStream = VideoStream()
    @StateObject var viewCounting = ViewCounting()
    
    // Prompt user for review
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        if (!videoStream.cameraAccess) {
            Text("This app requires authorization to access your camera in order to work correctly. You may grant this access from your device settings menu.")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
        } else {
            
            NavigationView {
                VStack {
                    if (videoStream.session != nil) {
                        VideoPreviewHolder(runningSession: videoStream.session)
                            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ProgressView()
                    }
                    Text(String(format: "%.0f  Lux", videoStream.luminosityReading))
                        .font(.system(size: 50))
                        .padding()
                        .toolbar {
                            ToolbarItem(id: "ReferenceButton", placement: .bottomBar) {
                                NavigationLink(destination: ReferenceView()) {
                                    Image(systemName: "info.circle")
                                }
                            }
                        }
                    
                }.onAppear{
                    print("View has been loaded \(viewCounting.viewCounter) times.")
                    
                    if viewCounting.viewCounter > 10 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                            requestReview()
                        })
                    } else {
                        viewCounting.viewCounter += 1
                        UserDefaults.standard.set(viewCounting.viewCounter, forKey: "ViewCounter")
                    }
                }
            }
        }
    }
}


/*
 Account for how many times the view has been loaded.
 If the view has been loaded more than ten times, request the user
 to review the app.
 */
class ViewCounting: ObservableObject {
    public var viewCounter: Int = (UserDefaults.standard.object(forKey: "ViewCounter") as? Int) ?? 0
}


