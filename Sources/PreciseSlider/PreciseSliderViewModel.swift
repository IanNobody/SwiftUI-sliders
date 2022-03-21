//
//  PreciseSliderViewModel.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 11.02.2022.
//

import Foundation
import SwiftUI

open class PreciseSliderViewModel: ObservableObject {
    @Published public private(set) var value: Double
    @Published public private(set) var scale: Double
    @Published public private(set) var isEditing: Bool = false
    
    public init(defaultValue: Double = Double.zero, defaultScale: Double = 1.0, minValue: Double = 0, maxValue: Double = 100, minScale: Double = 1.0, maxScale: Double = .infinity, unitSize: Double = 0, isInfinite: Bool = false) {
        self.value = defaultValue
        self.prevValue = defaultValue
        self.scale = defaultScale
        self.prevScale = defaultScale
        self.minValue = minValue
        self.maxValue = maxValue
        self.minScale = minScale
        self.maxScale = maxScale
        self.unitSize = unitSize
        self.isInfinite = isInfinite
    }
    
    public var defaultValue: Double {
        get {
            value
        }
        set {
            value = newValue
            prevValue = newValue
        }
    }
    
    public var defaultScale: Double {
        get {
            scale
        }
        set {
            scale = newValue
            prevScale = newValue
        }
    }

    public var safeValue: Double {
        if value > maxValue {
            return maxValue
        }
        
        if value < minValue {
            return minValue
        }
        
        return value
    }
    
    public var prevValue: Double
    public var prevScale: Double
    
    // Meze posuvníku
    public var maxValue: Double
    public var minValue: Double
    
    public var maxScale: Double
    public var minScale: Double
    
    public var isInfinite: Bool
    
    // Výchozí vzdálenost mezi jednotkami
    public var unitSize: CGFloat
    
    public var defaultStep: CGFloat {
        unitSize / 5
    }
    
    public var truncScale: Double {
        scale / scaleBase
    }
    
    public var scaleBase: Double {
        let exponent = floor(log(scale) / log(5))
        return pow(5, exponent)
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
        isEditing = true
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
        isEditing = true
    }
    
    open func animateMomentum(byValue difference: CGFloat, duration: CGFloat) {
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
        isEditing = false
    }
    
    public func editingScaleEnded() {
        prevScale = scale
        isEditing = false
    }
}
