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
    
    public init(defaultValue: Double = Double.zero, defaultScale: Double = 1.0, minValue: Double = 0, maxValue: Double = 100, minScale: Double = 1.0, maxScale: Double = .infinity, numberOfUnits: Int = 20, isInfinite: Bool = false) {
        self.value = defaultValue
        self.prevValue = defaultValue
        self.scale = defaultScale
        self.prevScale = defaultScale
        self.minValue = minValue
        self.maxValue = maxValue
        self.minScale = minScale
        self.maxScale = maxScale
        self.numberOfUnits = numberOfUnits * 5
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
    
    public var numberOfUnits: Int
    
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
        
        if (newValue > maxValue || newValue < minValue) {
            if !isInfinite {
                let difference = newValue - (newValue > maxValue ? maxValue : minValue)
            
                newValue = newValue > maxValue ?
                    maxValue + pow(abs(difference), 1/2) :
                    minValue - pow(abs(difference), 1/2)
            }
            else {
                if newValue > maxValue {
                    newValue = (newValue - minValue).truncatingRemainder(dividingBy: (minValue - maxValue)) + minValue
                }
                else {
                    newValue = (newValue - minValue).truncatingRemainder(dividingBy: (minValue - maxValue)) + maxValue
                }
            }
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
        
        prevValue = value
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
    
    public func zoom(toValue newScale: CGFloat) {
        if newScale > maxScale {
            scale = maxScale
        }
        else if newScale < minScale {
            scale = minScale
        }
        else {
            scale = newScale
        }
        
        prevScale = scale
    }
    
    open func animateOutsideHardBounds(to newValue: CGFloat, by difference: CGFloat, with duration: CGFloat) {
        if value > minValue && value < maxValue
                && !isInfinite {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75, blendDuration: 0.0)) {
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
    
    func animateOutsideSoftBounds(to newValue: CGFloat, with duration: CGFloat) {
        var destValue = newValue
        
        if newValue > maxValue {
            destValue = (newValue - minValue).truncatingRemainder(dividingBy: (maxValue - minValue)) + minValue
            value = destValue - (maxValue - minValue) //value - (newValue - minValue) - destValue
            prevValue = value
        }
        else {
            destValue = (newValue - minValue).truncatingRemainder(dividingBy: (maxValue - minValue)) + maxValue
            value = destValue + (maxValue - minValue) //value - (newValue - minValue) - destValue
            prevValue = value
        }

        withAnimation(.easeOut(duration: duration)) {
            value = destValue
            prevValue = destValue
        }
    }
    
    open func animateMomentum(byValue difference: CGFloat, duration: CGFloat) {
        let newValue = value - (difference / scale)
        
        withAnimation(.linear(duration: 0)) {
            value = value
            prevValue = value
        }
        
        if value > minValue && value < maxValue &&
            newValue > minValue && newValue < maxValue {
            withAnimation(.easeOut(duration: duration)) {
                value = newValue
                prevValue = newValue
            }
        }
        else {
            if isInfinite {
                animateOutsideSoftBounds(to: newValue, with: duration)
            }
            else {
                animateOutsideHardBounds(to: newValue, by: difference, with: duration)
            }
        }
    }
    
    //
    
    open func editingValueEnded() {
        prevValue = value
        isEditing = false
    }
    
    public func editingScaleEnded() {
        prevScale = scale
    }
}
