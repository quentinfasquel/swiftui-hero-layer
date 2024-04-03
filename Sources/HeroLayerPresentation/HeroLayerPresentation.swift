//
//  HeroLayerPresentation.swift
//  HeroLayerPresentation
//
//  Created by Quentin Fasquel on 30/03/2024.
//

import SwiftUI

fileprivate struct HeroAnchorKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Source View

public struct SourceView<Content: View>: View {
    @EnvironmentObject private var heroModel: HeroModel

    public var id: String
    public var content: Content

    public init(id: String, @ViewBuilder _ content: () -> Content) {
        self.id = id
        self.content = content()
    }

    public var body: some View {
        content
            .opacity(opacity)
            .anchorPreference(key: HeroAnchorKey.self, value: .bounds) { anchor in
                if let index, heroModel.info[index].isActive {
                    return [id: anchor]
                }
                return [:]
            }
            .onPreferenceChange(HeroAnchorKey.self) { value in
                if let index, heroModel.info[index].isActive, heroModel.info[index].sourceAnchor == nil {
                    print("got source \(id)")
                    heroModel.info[index].sourceAnchor = value[id]
                }
            }
    }

    var index: Int? {
        heroModel.info.firstIndex(where: { $0.infoID == id })
    }

    var opacity: CGFloat {
        if let index {
            return heroModel.info[index].isActive ? 0 : 1
        }
        return 1
    }
}


// MARK: - Destination View

public struct DestinationView<Content: View>: View {
    @EnvironmentObject private var heroModel: HeroModel

    public var id: String
    public var content: Content

    public init(id: String, @ViewBuilder _ content: () -> Content) {
        self.id = id
        self.content = content()
    }

    public var body: some View {
        content
            .opacity(opacity)
            .anchorPreference(key: HeroAnchorKey.self, value: .bounds) { anchor in
                if let index, heroModel.info[index].isActive {
                    return ["\(id)DESTINATION": anchor]
                }
                return [:]
            }
            .onPreferenceChange(HeroAnchorKey.self) { value in
                if let index, heroModel.info[index].isActive {
                    heroModel.info[index].destinationAnchor = value["\(id)DESTINATION"]
                }
            }
    }

    var index: Int? {
        heroModel.info.firstIndex(where: { $0.infoID == id })
    }

    var opacity: CGFloat {
        if let index {
            return heroModel.info[index].isActive ? (heroModel.info[index].hideView ? 1 : 0) : 0
        }
        return 1
    }
}

// MARK: - Hero Layer Modifier

fileprivate struct HeroLayerModifier<Layer: View>: ViewModifier {
    @EnvironmentObject private var heroModel: HeroModel

    var id: String
    @Binding var animate: Bool
    var sourceCornerRadius: CGFloat
    var destinationCornerRadius: CGFloat
    @ViewBuilder var layer: Layer
    var completion: (Bool) -> Void

    func body(content: Content) -> some View {
        content.onAppear {
            if !heroModel.info.contains(where: { $0.infoID == id }) {
                heroModel.info.append(HeroInfo(id: id))
            }
        }.onChange(value: animate) { newValue in
            if let index = heroModel.info.firstIndex(where: { $0.infoID == id }) {
                heroModel.info[index].isActive = true
                heroModel.info[index].layerView = AnyView(layer)
                heroModel.info[index].sourceCornerRadius = sourceCornerRadius
                heroModel.info[index].destinationCornerRadius = destinationCornerRadius
                heroModel.info[index].completion = completion

                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.snappy) {
                            heroModel.info[index].animationView = true
                        }
                    }
                } else {
                    heroModel.info[index].hideView = false
                    withAnimation(.snappy) {
                        heroModel.info[index].animationView = false
                    }
                }
            }
        }
    }
}

public extension View {

    @ViewBuilder
    func heroLayer<Content: View>(
        id: String,
        animate: Binding<Bool>,
        sourceCornerRadius: CGFloat = 0,
        destinationCornerRadius: CGFloat = 0,
        @ViewBuilder content: @escaping () -> Content,
        completion: @escaping (Bool) -> Void
    ) -> some View {
        self.modifier(HeroLayerModifier(
            id: id,
            animate: animate,
            sourceCornerRadius: sourceCornerRadius,
            destinationCornerRadius: destinationCornerRadius,
            layer: content,
            completion: completion
        ))
    }
}
