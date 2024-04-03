//
//  HeroModel.swift
//  HeroLayerPresentation
//
//  Created by Quentin Fasquel on 30/03/2024.
//

import SwiftUI

final class HeroModel: ObservableObject {
    @Published var info: [HeroInfo] = []
}

struct HeroInfo: Identifiable {
    private(set) var id: UUID = .init()
    private(set) var infoID: String
    var isActive: Bool = false
    var layerView: AnyView?
    var animationView: Bool = false
    var hideView: Bool = false
    var sourceAnchor: Anchor<CGRect>?
    var sourceCornerRadius: CGFloat = 0
    var destinationAnchor: Anchor<CGRect>?
    var destinationCornerRadius: CGFloat = 0
    var destinationInitialOffset: CGPoint = .zero
    var destinationDraggingOffset: CGPoint = .zero
    var completion: (Bool) -> Void = { _ in }

    init(id: String) {
        infoID = id
    }
}
