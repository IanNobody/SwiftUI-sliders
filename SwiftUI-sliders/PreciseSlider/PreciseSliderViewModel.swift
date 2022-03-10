//
//  PreciseSliderViewModel.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 11.02.2022.
//

import Foundation
import SwiftUI

class PreciseSliderViewModel: ObservableObject {
    @Published var value: Double = Double.zero {
        didSet {
            if value != oldValue {
                delegate?.valueDidChange(
                    value: cropToBoundaries(value: value)
                )
            }
        }
    }
    
    @Published var scale: Double = 1.0 {
        didSet {
            delegate?.scaleDidChange(scale: scale)
        }
    }
    
    public var prevValue: Double = Double.zero
    public var prevScale: Double = 1.0
    
    public var dataSource: PreciseSliderDataSource? {
        didSet {
            value = dataSource?.initialValue ?? Double.zero
            prevValue = value
            //
            scale = dataSource?.initialScale ?? 1.0
            prevScale = scale
        }
    }
    
    public var delegate: PreciseSliderDelegate?
    
    private let defaultMaxValue: Double = 1000.0
    private let defaultMinValue: Double = -1000.0
    
    // Meze posuvníku
    public var maxValue: Double {
        dataSource?.maximumValue ?? defaultMaxValue
    }
    
    public var minValue: Double {
        dataSource?.minimumValue ?? defaultMinValue
    }
    
    public var isInfinite: Bool {
        dataSource?.isFinite ?? false
    }
    
    // Výchozí vzdálenost mezi jednotkami
    public let defaultStep: CGFloat = 10.0
    
    public var truncScale: Double {
        scale / scaleBase
    }
    
    public var scaleBase: Double {
        let exponent = floor(log(scale) / log(5))
        return pow(5, exponent)
    }
    
    // Reálná hodnota zobrazené jednotky
    public var unit: CGFloat {
        Double(defaultStep) / scaleBase
    }
    
    // Grafická vzdálenost jedné jednotky
    public var designUnit: CGFloat {
        CGFloat(defaultStep) * truncScale
    }
    
    //
    
    private func cropToBoundaries(value: CGFloat) -> CGFloat {
        if !isInfinite && (value < minValue || value > maxValue) {
            return value < minValue ? minValue : maxValue
        }
        else {
            return value
        }
    }
    
    public func move(byValue difference: CGFloat) {
        var newValue = prevValue - (difference / scale)
        
        if (newValue > maxValue || newValue < minValue) && !isInfinite {
            let difference = newValue - (newValue > maxValue ? maxValue : minValue)
            
            newValue = newValue > maxValue ?
                maxValue + pow(abs(difference), 1/2) :
                minValue - pow(abs(difference), 1/2)
        }
        
        value = newValue
    }
    
    public func animateMomentum(byValue difference: CGFloat, duration: CGFloat) {
        let newValue = value - (difference / scale)
        
        if value > minValue && value < maxValue &&
            newValue > minValue && newValue < maxValue
            && !isInfinite {
            withAnimation(.easeOut(duration: duration)) {
                value = newValue
                prevValue = newValue
            }
        }
        else if value > minValue && value < maxValue
                && !isInfinite {
            withAnimation(.easeOut(duration: duration)) {
                move(byValue: difference)
                editingValueEnded()
            }
            withAnimation(.spring()) {
                value = newValue > maxValue ? maxValue : minValue
                prevValue = newValue > maxValue ? maxValue : minValue
            }
        }
        else {
            withAnimation(.spring()) {
                value = value > maxValue ? maxValue : minValue
                prevValue = value > maxValue ? maxValue : minValue
            }
        }
    }
    
    //
    
    public func editingValueEnded() {
        prevValue = value
    }
    
    public func editingScaleEnded() {
        prevScale = scale
    }
}
