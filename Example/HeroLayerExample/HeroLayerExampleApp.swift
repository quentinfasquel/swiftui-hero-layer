//
//  HeroLayerExampleApp.swift
//  HeroLayerExample
//
//  Created by Quentin Fasquel on 03/04/2024.
//

import HeroLayerPresentation
import SwiftUI

@main
struct HeroLayerExampleApp: App {
    var body: some Scene {
        WindowGroup {
            HeroWrapper {
                ContentView()
            }
        }
    }
}
