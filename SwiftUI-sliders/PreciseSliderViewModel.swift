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
    public var prevScale: Double = Double.zero
    
    // Proměnné pro řízení animované setrvačnosti osy
    private var destValue: Double = Double.zero
    private var animationTimer: Timer?
    
    public var dataSource: PreciseSliderDataSource? {
        didSet {
            value = dataSource?.preciseSliderInitialValue() ?? Double.zero
            prevValue = value
            //
            scale = dataSource?.preciseSliderInitialScale() ?? 1.0
            prevScale = scale
        }
    }
    
    public var delegate: PreciseSliderDelegate?
    
    // Meze posuvníku
    public var maxValue: Double {
        get {
            return dataSource?.preciseSliderMaximalValue() ?? 1000.0
        }
    }
    
    public var minValue: Double {
        get {
            return dataSource?.preciseSliderMinimalValue() ?? -1000.0
        }
    }
    
    public var isInfinite: Bool {
        get {
            return dataSource?.preciseSliderFinity() ?? true
        }
    }
    
    // Počet jednotek osy
    // TODO: Implementovat dynamiku v závislosti na rozměrech
    public var numberOfUnits: Int = 41
    
    private let maxUnitHeight: CGFloat = 25.0
    
    // Index středu osy
    public var middleIndex: Int {
        return (numberOfUnits / 2) + 1
    }
    
    // Výchozí vzdálenost mezi jednotkami
    private let defaultStep: CGFloat = 10.0
    
    public var truncScale: Double {
        return scale / scaleBase
    }
    
    public var scaleBase: Double {
        let exponent = floor(log(scale) / log(5))
        return pow(5, exponent)
    }
    
    // Reálná hodnota zobrazené jednotky
    public var unit: CGFloat {
        return Double(defaultStep) / scaleBase
    }
    
    // Grafická vzdálenost jedné jednotky
    public var designUnit: CGFloat {
        return CGFloat(defaultStep) * truncScale
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
    
    public func getUnitHeight(ofIndex index: Int) -> CGFloat {
        if getRelativeIndex(ofIndex: index) % 5 != 0 {
            let height = (truncScale - 1) / 3 * maxUnitHeight
            return height < maxUnitHeight ? height : maxUnitHeight
        }
        //
        return maxUnitHeight
    }
    
    public func getUnitOpacity(ofIndex index: Int) -> Double {
        if (getUnitValue(ofIndex: index) > maxValue ||
            getUnitValue(ofIndex: index) < minValue) &&
            !isInfinite {
            return 0.0
        }
        else {
            return 1.0
        }
    }
    
    public func getRelativeIndex(ofIndex index: Int) -> Int {
        return index
            + Int((value / unit).truncatingRemainder(dividingBy: 5))
            - Int(middleIndex % 5)
    }
    
    public func getUnitOffset(ofIndex index: Int) -> CGSize {
        let offset = (
            (CGFloat(index) * designUnit)
            - (CGFloat(middleIndex) * designUnit)
            - offset
        )
        
        return .init(width: offset, height: .zero)
    }
        
    public func getUnitValue(ofIndex index: Int) -> Double {
        return (
            value
            - (offset / designUnit * unit)
            + (unit * Double(index - middleIndex))
        )
    }
}
