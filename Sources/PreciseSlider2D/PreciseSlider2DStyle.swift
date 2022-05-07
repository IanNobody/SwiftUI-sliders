//
//  PreciseSlider2DStyle.swift
//  
//
//  Created by Šimon Strýček on 26.03.2022.
//

import SwiftUI

public class PreciseSlider2DStyle {
    public var axisBackgroundColor: Color
    public var axisPointerColor: Color
    public var background: PreciseSlider2DBackground
    public var pointerColor: PreciseSlider2DPointerColor
    public var pointerSize: CGSize
    public var unitColor: (_ value: Double, _ isHighlighted: Bool) -> Color

    init(axisBackgroundColor: Color = .black,
         axisPointerColor: Color = .blue,
         background: PreciseSlider2DBackground = .blurredContent,
         pointerColor: PreciseSlider2DPointerColor = .invertedColor,
         pointerSize: CGSize = CGSize(width: 20, height: 20),
         unitColor: @escaping (_ value: Double, _ isHighlighted: Bool) -> Color = { _, _ in .white }) {
        self.axisBackgroundColor = axisBackgroundColor
        self.axisPointerColor = axisPointerColor
        self.background = background
        self.pointerColor = pointerColor
        self.pointerSize = pointerSize
        self.unitColor = unitColor
    }

    // Pozadí osy
    public enum PreciseSlider2DBackground: Equatable {
        case blurredContent
        case color(Color)

        init(uiSliderBackground background: UIPreciseSlider2DBackground) {
            switch background {
            case .color(let color):
                self = .color(Color(uiColor: color))
            case .blurredContent:
                self = .blurredContent
            }
        }
    }

    public enum UIPreciseSlider2DBackground: Equatable {
        case blurredContent
        case color(UIColor)

        init(sliderBackground background: PreciseSlider2DBackground) {
            switch background {
            case .color(let color):
                self = .color(UIColor(color))
            case .blurredContent:
                self = .blurredContent
            }
        }
    }

    // Barva ukazatele
    public enum PreciseSlider2DPointerColor: Equatable {
        case invertedColor
        case staticColor(Color)

        init(uiPointerColor color: UIPreciseSlider2DPointerColor) {
            switch color {
            case .staticColor(let color):
                self = .staticColor(Color(uiColor: color))
            case .invertedColor:
                self = .invertedColor
            }
        }
    }

    public enum UIPreciseSlider2DPointerColor: Equatable {
        case invertedColor
        case staticColor(UIColor)

        init(pointerColor color: PreciseSlider2DPointerColor) {
            switch color {
            case .staticColor(let color):
                self = .staticColor(UIColor(color))
            case .invertedColor:
                self = .invertedColor
            }
        }
    }
}

//
// Částečně převzato z:
//
// Styling custom SwiftUI views using environment (9.12.2020)
// Autor: Majid Jabrayilov
// URL: https://swiftwithmajid.com/2020/12/09/styling-custom-swiftui-views-using-environment/
//

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

//
// Konec převzaté části
//
