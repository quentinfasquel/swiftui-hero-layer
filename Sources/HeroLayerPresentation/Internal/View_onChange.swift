//
//  View_onChange.swift
//  HeroLayerPresentation
//
//  Created by Quentin Fasquel on 30/03/2024.
//

import SwiftUI

extension View {

    @ViewBuilder
    func onChange<Value: Equatable>(
        value: Value,
        completion: @escaping (Value) -> Void
    ) -> some View {
        if #available(iOS 17, *) {
            self.onChange(of: value) { oldValue, newValue in
                completion(newValue)
            }
        } else {
            self.onChange(of: value) { value in
                completion(value)
            }
        }
    }
}
