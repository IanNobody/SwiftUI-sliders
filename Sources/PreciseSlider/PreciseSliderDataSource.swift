//
//  PreciseSliderDataSource.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 11.02.2022.
//

#if !os(macOS)

import UIKit
import SwiftUI

public protocol PreciseSliderDataSource: AnyObject {
    var defaultValue: Double { get }
    var defaultScale: Double { get }
    var minValue: Double { get }
    var maxValue: Double { get }
    var minScale: Double { get }
    var maxScale: Double { get }
    var numberOfUnits: Int { get }
    var isInfinite: Bool { get }

    //
    func unitLabelText(for value: Double, with stepSize: Double) -> String
    func unitLabelColor(for value: Double, with stepSize: Double) -> UIColor
    func unitLabelFont(for value: Double, with stepSize: Double) -> UIFont
}

public extension PreciseSliderDataSource {
    var defaultValue: Double { 0 }
    var defaultScale: Double { 1 }
    var minValue: Double { 0 }
    var maxValue: Double { 100 }
    var minScale: Double { 1 }
    var maxScale: Double { 10 }
    var numberOfUnits: Int { 40 }
    var isInfinite: Bool { false }

    func unitLabelText(for value: Double, with stepSize: Double) -> String {
        String(value)
    }

    func unitLabelColor(for value: Double, with stepSize: Double) -> UIColor {
        .white
    }

    func unitLabelFont(for value: Double, with stepSize: Double) -> UIFont {
        UIFont.systemFont(ofSize: 6)
    }
}

#endif
