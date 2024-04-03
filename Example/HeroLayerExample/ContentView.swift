//
//  ContentView.swift
//  HeroLayerExample
//
//  Created by Quentin Fasquel on 03/04/2024.
//

import HeroLayerPresentation
import SwiftUI

struct ContentView: View {
    @State private var showFullscreen: Bool = false

    var body: some View {
        VStack {
            SourceView(id: "view1") {
                Circle().fill(.red)
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        showFullscreen.toggle()
                    }
            }
        }
        .padding()
        .sheet(isPresented: $showFullscreen) {
            DestinationView(id: "view1") {
                Circle().fill(.red)
                    .frame(width: 150, height: 150)
                    .onTapGesture {
                        print("did tap")
                        showFullscreen.toggle()
                    }
            }
            .padding(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .interactiveDismissDisabled()
        }
        .heroLayer(id: "view1", animate: $showFullscreen) {
            Circle().fill(.red)
        } completion: { _ in

        }
    }
}

#Preview {
    ContentView()
}
