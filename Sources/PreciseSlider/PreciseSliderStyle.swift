//
//  PreciseSliderStyle.swift
//  
//
//  Created by Šimon Strýček on 25.03.2022.
//

import SwiftUI

public class PreciseSliderStyle {
    public var backgroundColor: Color
    public var defaultUnitColor: Color
    public var highlightedUnitColor: Color
    public var axisPointerColor: Color
    
    public init(backgroundColor: Color = .black, defaultUnitColor: Color = .white, highlitedUnitColor: Color, axisPointerColor: Color = .blue) {
        self.backgroundColor = backgroundColor
        self.defaultUnitColor = defaultUnitColor
        self.highlightedUnitColor = highlitedUnitColor
        self.axisPointerColor = axisPointerColor
    }
    
    // Konstruktor s výchozí barvou zvýrazněné jednotky
    public init(backgroundColor: Color = .black, defaultUnitColor: Color = .white, axisPointerColor: Color = .blue) {
        self.backgroundColor = backgroundColor
        self.defaultUnitColor = defaultUnitColor
        self.highlightedUnitColor = defaultUnitColor
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
