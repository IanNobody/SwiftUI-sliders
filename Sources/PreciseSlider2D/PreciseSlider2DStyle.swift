//
//  PreciseSlider2DStyle.swift
//  
//
//  Created by Šimon Strýček on 26.03.2022.
//

import SwiftUI

public class PreciseSlider2DStyle {
    public let axisBackgroundColor: Color
    public let axisPointerColor: Color
    public let defaultUnitColor: Color
    public let highlightedUnitColor: Color
    public let background: PreciseSlider2DBackground
    public let pointerColor: PreciseSlider2DPointerColor
    public let pointerSize: CGSize
    
    init(axisBackgroundColor: Color = .black, axisPointerColor: Color = .blue, defaultUnitColor: Color = .white, highlightedColor: Color, background: PreciseSlider2DBackground = .blurredContent, pointerColor: PreciseSlider2DPointerColor = .invertedColor, pointerSize: CGSize = CGSize(width: 20, height: 20)) {
        self.axisBackgroundColor = axisBackgroundColor
        self.axisPointerColor = axisPointerColor
        self.defaultUnitColor = defaultUnitColor
        self.highlightedUnitColor = highlightedColor
        self.background = background
        self.pointerColor = pointerColor
        self.pointerSize = pointerSize
    }
    
    init(axisBackgroundColor: Color = .black, axisPointerColor: Color = .blue, defaultUnitColor: Color = .white, background: PreciseSlider2DBackground = .blurredContent, pointerColor: PreciseSlider2DPointerColor = .invertedColor, pointerSize: CGSize = CGSize(width: 20, height: 20)) {
        self.axisBackgroundColor = axisBackgroundColor
        self.axisPointerColor = axisPointerColor
        self.defaultUnitColor = defaultUnitColor
        self.highlightedUnitColor = defaultUnitColor
        self.background = background
        self.pointerColor = pointerColor
        self.pointerSize = pointerSize
    }
    
    public enum PreciseSlider2DBackground: Equatable {
        case blurredContent
        case color(Color)
    }
    
    public enum PreciseSlider2DPointerColor: Equatable {
        case invertedColor
        case staticColor(Color)
    }
}

struct PreciseSlider2DStyleEnviromentKey: EnvironmentKey {
    static var defaultValue: PreciseSlider2DStyle = .init()
}

extension EnvironmentValues {
    var preciseSlider2DStyle: PreciseSlider2DStyle {
        get { self[PreciseSlider2DStyleEnviromentKey.self] }
        set { self[PreciseSlider2DStyleEnviromentKey.self] = newValue }
    }
}

extension View {
    public func preciseSlider2DStyle(_ style: PreciseSlider2DStyle) -> some View {
        environment(\.preciseSlider2DStyle, style)
    }
}
