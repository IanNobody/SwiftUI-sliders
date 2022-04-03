//
//  PreciseSliderStyle.swift
//  
//
//  Created by Šimon Strýček on 25.03.2022.
//

import SwiftUI

public struct PreciseSliderStyle {
    public let backgroundColor: Color
    public let defaultUnitColor: Color
    public let highlitedUnitColor: Color
    public let axisPointerColor: Color
    
    public init(backgroundColor: Color = .black, defaultUnitColor: Color = .white, highlitedUnitColor: Color, axisPointerColor: Color = .blue) {
        self.backgroundColor = backgroundColor
        self.defaultUnitColor = defaultUnitColor
        self.highlitedUnitColor = highlitedUnitColor
        self.axisPointerColor = axisPointerColor
    }
    
    // Konstruktor s výchozí barvou zvýrazněné jednotky
    public init(backgroundColor: Color = .black, defaultUnitColor: Color = .white, axisPointerColor: Color = .blue) {
        self.backgroundColor = backgroundColor
        self.defaultUnitColor = defaultUnitColor
        self.highlitedUnitColor = defaultUnitColor
        self.axisPointerColor = axisPointerColor
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
