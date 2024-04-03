//
//  HeroWrapper.swift
//  HeroLayerPresentation
//
//  Created by Quentin Fasquel on 30/03/2024.
//

import SwiftUI

public struct HeroWrapper<Content: View>: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var heroModel = HeroModel()
    @State private var overlayWindow: UIWindow?

    public var content: Content

    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .onChange(value: scenePhase) { newPhase in
                if case .active = newPhase {
                    addOverlayWindow()
                }
            }
            .environmentObject(heroModel)
    }

    func addOverlayWindow() {
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene, scene.activationState == .foregroundActive, overlayWindow == nil {
                let window = PassthroughWindow(windowScene: windowScene)
                window.backgroundColor = .clear
                window.isUserInteractionEnabled = false
                window.isHidden = false
                let rootViewController = UIHostingController(rootView: HeroWrapperTransitionView().environmentObject(heroModel))
                rootViewController.view.frame = windowScene.screen.bounds
                rootViewController.view.backgroundColor = .clear
                window.rootViewController = rootViewController
                overlayWindow = window
                break
            }
        }

        if overlayWindow == nil {
            // No window scene found
        }
    }
}

// MARK: - Passthrough Window

fileprivate final class PassthroughWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}

// MARK: - Hero Wrapper Transition View

fileprivate struct HeroWrapperTransitionView: View {
    @EnvironmentObject private var heroModel: HeroModel

    var body: some View {
        GeometryReader { geometry in
            ForEach($heroModel.info) { $info in
                ZStack {
                    if let source = info.sourceAnchor,
                       let destination = info.destinationAnchor,
                       let layerView = info.layerView, !info.hideView {
                        let animateView = info.animationView
                        let sourceRect = geometry[source]
                        let destinationRect = geometry[destination]
                        let layerRect = animateView ? destinationRect : sourceRect
                        let layerCornerRadius = animateView ? info.destinationCornerRadius : info.sourceCornerRadius
                        let dy = info.destinationDraggingOffset.y - info.destinationInitialOffset.y

                        layerView
                            .frame(width: layerRect.width, height: layerRect.height)
                            .clipShape(.rect(cornerRadius: layerCornerRadius))
                            .offset(x: layerRect.minX, y: layerRect.minY + (animateView ? dy : 0))
                            .transition(.identity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
                .onChange(value: info.animationView) { animateView in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        if !animateView {
                            info.isActive = false
                            info.layerView = nil
                            info.sourceAnchor = nil
                            info.sourceCornerRadius = 0
                            info.destinationAnchor = nil
                            info.destinationCornerRadius = 0
                            info.completion(false)
                        } else {
                            info.hideView = true
                            info.completion(true)
                        }
                    }
                }

            }
        }
    }
}
