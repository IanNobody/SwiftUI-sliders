//
//  PreciseSliderDelegate.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 12.02.2022.
//

#if !os(macOS)

public protocol PreciseSliderDelegate: AnyObject {
    func valueDidChange(value: Double)
    func scaleDidChange(scale: Double)
    func didBeginEditing()
    func didEndEditing()
}

public extension PreciseSliderDelegate {
    func valueDidChange(value: Double) {}
    func scaleDidChange(scale: Double) {}
    func didBeginEditing() {}
    func didEndEditing() {}
}

#endif
