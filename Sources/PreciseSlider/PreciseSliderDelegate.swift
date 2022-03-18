//
//  PreciseSliderDelegate.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 12.02.2022.
//

protocol PreciseSliderDelegate: AnyObject {
    func valueDidChange(value: Double)
    func scaleDidChange(scale: Double)
}
