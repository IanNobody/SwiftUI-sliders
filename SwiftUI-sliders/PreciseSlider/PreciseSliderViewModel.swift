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
            delegate?.valueDidChange(value: value)
        }
    }
    
    @Published var scale: Double = 1.0 {
        didSet {
            delegate?.scaleDidChange(scale: scale)
        }
    }
    
    public var prevValue: Double = Double.zero
    public var prevScale: Double = 1.0
    
    // Proměnné pro řízení animované setrvačnosti osy
    private var destValue: Double = Double.zero
    private var animationTimer: Timer?
    
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
    
    // Posuv osy v rámci jedné jednotky
    public var offset: CGFloat {
        (value / unit) * designUnit
    }
    
    //
    
    public func move(byValue difference: CGFloat) {
        let newValue = prevValue - (difference / scale)
        
        if !isInfinite && (newValue < minValue || newValue > maxValue) {
            value = newValue < minValue ?
                minValue : maxValue
        }
        else {
            value = newValue
        }
    }
    
    public func unitHeightRatio(forIndex index: Int) -> CGFloat {
        if index % 5 != 0 {
            let height = (truncScale - 1) / 3
            return height < 1 ? height : 1
        }
        //
        return 1
    }
    
    //
    
    public func animateMomentum(byValue difference: Double) {
        destValue = value + difference
        animationTimer = Timer.scheduledTimer(
            // TODO: Zajistit dynamiku
            timeInterval: 1/60,
            target: self,
            selector: #selector(makeAnimationStep),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func makeAnimationStep() {
        if abs(destValue - value) < (unit / designUnit) {
            interruptAnimation()
        }
        else {
            value += (destValue - value) / 10
            prevValue = value
        }
    }
    
    public func interruptAnimation() {
        if animationTimer != nil {
            if animationTimer?.isValid == true {
                animationTimer?.invalidate()
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
    
    public func unitOffset(forIndex index: Int) -> CGFloat {
        let offset = (
            (CGFloat(index) * designUnit)
            - offset
        )
        
        return offset
    }
}
