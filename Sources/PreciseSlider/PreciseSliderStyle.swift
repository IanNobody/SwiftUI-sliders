//
//  PreciseSliderStyle.swift
//  
//
//  Created by Šimon Strýček on 25.03.2022.
//

import SwiftUI

public class PreciseSliderStyle {
    public var backgroundColor: Color
    public var axisPointerColor: Color
    
    public var unitColor: (_ value: Double, _ isHighlited: Bool) -> Color
    
    public init(backgroundColor: Color = .black, axisPointerColor: Color = .blue, unitColor: @escaping (_ value: Double, _ isHighlited: Bool) -> Color = { _, _ in .white }) {
        self.backgroundColor = backgroundColor
        self.axisPointerColor = axisPointerColor
        self.unitColor = unitColor
    }
}

struct PreciseSliderStyleEnviromentKey: EnvironmentKey {
    static var defaultValue: PreciseSliderStyle = .init()
}

extension EnvironmentValues {
    var preciseSliderStyle: PreciseSliderStyle {
        get { self[PreciseSliderStyleEnviromentKey.self] }
        set { self[PreciseSliderStyleEnviromentKey.self] = newValue }
    }
}

extension View {
    public func preciseSliderStyle(_ style: PreciseSliderStyle) -> some View {
        environment(\.preciseSliderStyle, style)
    }
}
