//
//  PreciseSliderViewModel.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 11.02.2022.
//

import Foundation
import SwiftUI

class PreciseSliderViewModel: ObservableObject {
    @Published var value: Double = Double.zero
    @Published var scale: Double = 1.0
    
    public var prevValue: Double = Double.zero
    public var prevScale: Double = 1.0
    
    // Meze posuvníku
    public var maxValue: Double = 200 // Výchozí meze
    public var minValue: Double = -200
    
    public var maxScale: Double = .infinity
    public var minScale: Double = 1.0
    
    public var isInfinite: Bool = false
    
    // Výchozí vzdálenost mezi jednotkami
    public let defaultStep: CGFloat = 20.0
    
    public var truncScale: Double {
        scale / scaleBase
    }
    
    public var scaleBase: Double {
        let exponent = floor(log(scale) / log(5))
        return pow(5, exponent)
    }
    
    // TODO: Po přesunutí do View smazat
    // Reálná hodnota zobrazené jednotky
    public var unit: CGFloat {
        Double(defaultStep) / scaleBase
    }
    
    // Grafická vzdálenost jedné jednotky
    public var designUnit: CGFloat {
        CGFloat(defaultStep) * truncScale
    }
    
    //
    
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
    
    public func move(toValue newValue: CGFloat) {
        if newValue > maxValue {
            value = maxValue
        }
        else if newValue < minValue {
            value = minValue
        }
        else {
            value = newValue
        }
        
        editingValueEnded()
    }
    
    public func zoom(byScale zoom: CGFloat) {
        var newScale = prevScale * zoom
        
        if newScale > maxScale {
           newScale = maxScale
        }
        
        if newScale < minScale {
            newScale = minScale
        }
        
        scale = newScale
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
