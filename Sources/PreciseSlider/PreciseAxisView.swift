//
//  PreciseSliderAxisView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 07.03.2022.
//

import SwiftUI

struct PreciseAxisView<UnitLabel: View>: View, Animatable {
    @Environment(\.preciseSliderStyle) var style
    
    let maxValue: CGFloat
    let minValue: CGFloat
    
    var animatableData: CGFloat
    var value: CGFloat {
        animatableData
    }
    
    let truncScale: CGFloat
    let isInfinite: Bool
    let maxDesignValue: CGFloat
    let minDesignValue: CGFloat
    let scaleBase: CGFloat
    let stepSize: CGFloat
    
    @ViewBuilder let valueLabel: ((_ value: CGFloat, _ stepSize: CGFloat) -> UnitLabel)?
    
    init(maxValue: CGFloat, minValue: CGFloat, value: CGFloat, truncScale: CGFloat, isInfinite: Bool, maxDesignValue: CGFloat, minDesignValue: CGFloat, scaleBase: CGFloat, defaultStep: CGFloat, valueLabel: ((_ value: CGFloat, _ stepSize: CGFloat) -> UnitLabel)?) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.isInfinite = isInfinite
        self.maxDesignValue = maxDesignValue
        self.minDesignValue = minDesignValue
        self.scaleBase = scaleBase
        self.stepSize = defaultStep
        self.valueLabel = valueLabel
    }
    
    // TODO: Vyřešit nekonečnost osy (aktuálně hrozí přetečení relativního indexu)
    // TODO: Používat vlastní GeometryReader nebo si ho nechat předávat od parent View?
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadí
                Rectangle()
                    .foregroundColor(style.backgroundColor)
                //
                ForEach(0..<numberOfUnits(fromWidth: geometry.size.width), id: \.self) { index in
                    if isUnitVisible(ofIndex: index, withWidth: geometry.size.width)
                    {
                        PreciseUnitView(isHighlited: isUnitHighlited(ofIndex: index, withFrameSize: geometry.size)) {
                                valueLabel?(unitValue(forIndex: index, withWidth: geometry.size.width), truncScale > 3 ? unit : 5 * unit)
                                .zIndex(1)
                        }
                        .frame(width: maxLabelWidth(fromHeight: geometry.size.height), height: unitHeight(forIndex: index, withFrameSize: geometry.size))
                        .offset(
                            x: unitOffset(forIndex: index, withWidth: geometry.size.width)
                        )
                    }
                }
                
                // Zobrazení jednotky minimální hodnoty
                PreciseUnitView(isHighlited: true) {
                    valueLabel?(minValue, truncScale > 3 ? unit : 5 * unit)
                }
                .frame(
                    width: maxLabelWidth(fromHeight: geometry.size.height),
                    height: maxUnitHeight(fromHeight: geometry.size.height)
                )
                .offset(x: minBoundaryOffset)
                
                // Zobrazení jednotky maximální hodnoty
                PreciseUnitView(isHighlited: true) {
                    valueLabel?(maxValue, truncScale > 3 ? unit : 5 * unit)
                }
                .frame(
                    width: maxLabelWidth(fromHeight: geometry.size.height),
                    height: maxUnitHeight(fromHeight: geometry.size.height)
                )
                .offset(x: maxBoundaryOffset)
                
                // Středový bod
                Rectangle().frame(width: 1, height: geometry.size.height * 0.8).foregroundColor(style.axisPointerColor)
            }
        }
        .clipShape(Rectangle())
    }
    
    private func isUnitHighlited(ofIndex index: Int, withFrameSize frame: CGSize) -> Bool {
        (
            truncScale > 3.0
            || relativeIndex(forIndex: index, withWidth: frame.width) % 5 == 0
        )
        && !isUnitOverlapped(ofIndex: index, withFrameSize: frame)
    }
    
    private func maxLabelWidth(fromHeight height: CGFloat) -> CGFloat {
        // Jakýkoli index nedělitelný 5ti
        let minUnitHeight = minUnitHeightRatio * maxUnitHeight(fromHeight: height)
        
        // 1/3 = minimální zobrazitelný rozměr jednotky
        if minUnitHeight > (1/3) {
            return truncScale < 3 ?
                designUnit * 1.8 : designUnit * 0.8
        }
        else {
            return designUnit * 4.8
        }
    }
    
    private func maxLabelHeight(fromHeight height: CGFloat) -> CGFloat {
        maxUnitHeight(fromHeight: height) / 3
    }
    
    private var maxBoundaryOffset: CGFloat {
        (maxValue - value) / unit * designUnit
    }
    
    private var minBoundaryOffset: CGFloat {
        (minValue - value) / unit * designUnit
    }
    
    private func toDesignBase(value: CGFloat) -> CGFloat {
        value * (maxDesignValue - minDesignValue) / (maxValue - minValue)
    }
    
    public var defaultStep: CGFloat {
        if stepSize <= 0 {
            return 10 / (maxDesignValue - minDesignValue) * (maxValue - minValue)
        }
        else {
            return stepSize
        }
    }
    
    // Reálná hodnota jedné jednotky
    public var unit: CGFloat {
        defaultStep / scaleBase
    }
    
    // Grafická hodnota jedné jednotky
    public var designUnit: CGFloat {
        toDesignBase(value: defaultStep) * truncScale
    }
    
    private func unitOffset(forIndex index: Int, withWidth width: CGFloat) -> CGFloat {
        var offset = (CGFloat(index) * designUnit) - offset
        let max = maxUnitOffset(fromWidth: width)
        let scaleCorrection = designUnit * CGFloat(middleIndex(fromWidth: width))
        
        if offset > max {
            offset = offset.truncatingRemainder(dividingBy: max)
        }
        else if offset < 0 {
            offset = max + offset.truncatingRemainder(dividingBy: max)
        }
        
        return (offset - scaleCorrection)
    }
    
    private func numberOfUnits(fromWidth width: CGFloat) -> Int {
        let num = Int(ceil(width / CGFloat(designUnit)))
        
        // Zaokrouhlení k nejbližšímu vyššímu násobku 5
        // (5 = počet dílků jedné jednotky)
        let base = (num / 5) + 1
        
        //
        if base % 2 == 0 {
            return base * 5
        }
        else {
            return (base + 1) * 5
        }
    }
    
    private func middleIndex(fromWidth width: CGFloat) -> Int {
        return Int(numberOfUnits(fromWidth: width) / 2)
    }
    
    // Unikátní index každé jednotky
    public func relativeIndex(forIndex index: Int, withWidth width: CGFloat) -> Int {
        let indexOffset = index - Int(ceil(value / unit))
        let offsetRate = Int(floor(Float(abs(indexOffset)) / Float(numberOfUnits(fromWidth: width))))
        
        // Korekce zaokrouhlení pro záporná čísla
        if indexOffset < 0 {
            return index + (offsetRate + 1) * (numberOfUnits(fromWidth: width)) - middleIndex(fromWidth: width)
        }

        return index - (offsetRate * (numberOfUnits(fromWidth: width))) - middleIndex(fromWidth: width)
    }
    
    // Posun osy dle vybrané hodnoty
    public var offset: CGFloat {
        (value / unit) * designUnit
    }
    
    private func maxUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfUnits(fromWidth: width)) * designUnit
    }
    
    private var minUnitHeightRatio: CGFloat {
        let height = (truncScale - 1) / 3
        return height < 1 ? height : 1
    }
    
    public func unitHeightRatio(forIndex index: Int) -> CGFloat {
        if index % 5 != 0 {
            return minUnitHeightRatio
        }
        //
        return 1
    }
    
    private func maxUnitHeight(fromHeight height: CGFloat) -> CGFloat {
        return height / 2
    }
    
    public func unitHeight(forIndex index: Int, withFrameSize frame: CGSize) -> CGFloat {
        unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: frame.width)) * maxUnitHeight(fromHeight: frame.height)
    }
    
    public func isUnitOverlapped(ofIndex index: Int, withFrameSize frame: CGSize) -> Bool {
        if maxBoundaryOffset - unitOffset(forIndex: index, withWidth: frame.width) < maxLabelWidth(fromHeight: frame.height) {
            return true
        }
        
        if unitOffset(forIndex: index, withWidth: frame.width) - minBoundaryOffset < maxLabelWidth(fromHeight: frame.height) {
            return true
        }
        
        return false
    }
    
    public func isUnitVisible(ofIndex index: Int, withWidth width: CGFloat) -> Bool {
        if (unitValue(forIndex: index, withWidth: width) >= maxValue ||
            unitValue(forIndex: index, withWidth: width) <= minValue) &&
            !isInfinite {
            return false
        }
        else {
            return true
        }
    }
    
    public func unitValue(forIndex index: Int, withWidth width: CGFloat) -> Double {
            unit * Double(relativeIndex(forIndex: index, withWidth: width))
    }
}

struct PreciseAxisView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseAxisView(maxValue: 200.0, minValue: -200.0, value: 0, truncScale: 1, isInfinite: false, maxDesignValue: 300, minDesignValue: -300, scaleBase: 1.0, defaultStep: 4, valueLabel: { value, step in
                Text("\(value)")
                    .background(.black)
                    .font(.system(size:7, design: .rounded))
                    .foregroundColor(.white)
            }
        )
        .frame(width: 300, height: 50, alignment: .center)
    }
}
