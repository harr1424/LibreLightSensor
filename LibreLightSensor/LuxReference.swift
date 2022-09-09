//
//  LuxReference.swift
//  LibreLightSensor
//
//  Created by user on 9/7/22.
//

import SwiftUI

struct LuxReference: Identifiable {
    let reference: String
    let value: String
    let id = UUID()
}

struct compactLuxReference: Identifiable {
    // TODO delete this
    let reference: String
    let id = UUID()
}

let references = [
    LuxReference(reference: "Overcast night sky, no moon", value: "0.0001"),
    LuxReference(reference: "Full moon on a clear night", value: "0.3"),
    LuxReference(reference: "Horizon at dusk with a clear sky", value: "3.4"),
    LuxReference(reference: "Family living room lights (1998)", value: "50"),
    LuxReference(reference: "Public restroom", value: "80"),
    LuxReference(reference: "Very dark overcast day", value: "100"),
    LuxReference(reference: "Train station platform", value: "150"),
    LuxReference(reference: "Sunrise or sunset on a clear day", value: "400"),
    LuxReference(reference: "Office lighting", value: "500"),
    LuxReference(reference: "Overcast day", value: "1000"),
    LuxReference(reference: "Full daylight", value: "10,000 - 25,000"),
    LuxReference(reference: "Direct sunlight", value: "32,000 - 100,000")
]

let compactReferences = [
    // TODO delete this
    compactLuxReference(reference: "Overcast night sky, no moon: 0.0001"),
    compactLuxReference(reference: "Full moon on a clear night: 0.3"),
    compactLuxReference(reference: "Horizon at dusk with a clear sky: 3.4"),
    compactLuxReference(reference: "Family living room lights (1998): 50"),
    compactLuxReference(reference: "Public restroom: 80"),
    compactLuxReference(reference: "Very dark overcast day: 100"),
    compactLuxReference(reference: "Train station platform: 150"),
    compactLuxReference(reference: "Sunrise or sunset on a clear day: 400"),
    compactLuxReference(reference: "Office lighting: 500"),
    compactLuxReference(reference: "Overcast day: 1000"),
    compactLuxReference(reference: "Full daylight: 10,000 - 25,000"),
    compactLuxReference(reference: "Direct sunlight: 32,000 - 100,000")
]


struct ReferenceView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        
        if horizontalSizeClass == .compact{
            
            // TODO use an HStack to display two lists instead
            Table(compactReferences) {
                TableColumn("Sample Values", value: \.reference)
            }
        } else {
            Table(references) {
                TableColumn("Reference", value: \.reference)
                TableColumn("Value", value: \.value)
            }
        }
    }
}
