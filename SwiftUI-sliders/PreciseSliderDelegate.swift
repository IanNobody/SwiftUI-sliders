//
//  PreciseSliderDelegate.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 12.02.2022.
//

import Foundation

protocol PreciseSliderDelegate: NSObject {
    func valueDidChange(value: Double)
    func scaleDidChange(scale: Double)
}
