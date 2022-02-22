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
        dataSource?.isFinite ?? true
    }
    
    // Počet jednotek osy
    // TODO: Implementovat dynamiku v závislosti na rozměrech
    public var numberOfUnits: Int = 41
    
    private let maxUnitHeight: CGFloat = 25.0
    
    // Index středu osy
    public var middleIndex: Int {
        (numberOfUnits / 2) + 1
    }
    
    // Výchozí vzdálenost mezi jednotkami
    private let defaultStep: CGFloat = 10.0
    
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
        var truncValue = value.truncatingRemainder(dividingBy: unit)
        
        // Oprava nepřesností
        if (unit - truncValue) < (unit / 1000) {
            truncValue = 0
        }

        // Transformace do báze vizualizace
        return (truncValue / unit) * designUnit
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
    
    public func unitHeight(forIndex index: Int) -> CGFloat {
        if relativeIndex(forIndex: index) % 5 != 0 {
            let height = (truncScale - 1) / 3 * maxUnitHeight
            return height < maxUnitHeight ? height : maxUnitHeight
        }
        //
        return maxUnitHeight
    }
    
    public func unitVisibility(ofIndex index: Int) -> Bool {
        if (unitValue(forIndex: index) > maxValue ||
            unitValue(forIndex: index) < minValue) &&
            !isInfinite {
            return false
        }
        else {
            return true
        }
    }
    
    public func relativeIndex(forIndex index: Int) -> Int {
        return index
            + Int((value / unit).truncatingRemainder(dividingBy: 5))
            - Int(middleIndex % 5)
    }
    
    public func unitOffset(forIndex index: Int) -> CGSize {
        let offset = (
            (CGFloat(index) * designUnit)
            - (CGFloat(middleIndex) * designUnit)
            - offset
        )
        
        return .init(width: offset, height: .zero)
    }
        
    public func unitValue(forIndex index: Int) -> Double {
        return (
            value
            - (offset / designUnit * unit)
            + (unit * Double(index - middleIndex))
        )
    }
}
