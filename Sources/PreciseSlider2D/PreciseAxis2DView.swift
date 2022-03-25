//
//  PreciseAxisView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 16.02.2022.
//

import SwiftUI

struct PreciseAxis2DView<ValueLabel:View>: View, Animatable {
    let maxValue: CGFloat
    let minValue: CGFloat
    
    var animatableData: CGFloat
    var value: CGFloat {
        animatableData
    }
    
    let minDesignValue: CGFloat
    let maxDesignValue: CGFloat
    let stepSize: CGFloat
    let scaleBase: CGFloat
    let truncScale: CGFloat
    let isInfinite: Bool
    let active: Bool
    
    @ViewBuilder let valueLabel: ((_ forValue: Double) -> ValueLabel)?
    
    init(maxValue: CGFloat, minValue: CGFloat, value: CGFloat, truncScale: CGFloat, isInfinite: Bool, isActive: Bool, minDesignValue: CGFloat, maxDesignValue: CGFloat, defaultStep: CGFloat, scaleBase: CGFloat, valueLabel: ((_ forValue: Double) -> ValueLabel)?) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.isInfinite = isInfinite
        self.active = isActive
        self.minDesignValue = minDesignValue
        self.maxDesignValue = maxDesignValue
        self.scaleBase = scaleBase
        self.stepSize = defaultStep
        self.valueLabel = valueLabel
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .frame(
                        width: geometry.size.width,
                        height: axisHeight(
                            fromFrameHeight: geometry.size.height
                        ),
                        alignment: .leading)
                    .foregroundColor(.black)
                //
                ForEach(0..<numberOfUnits(fromWidth: geometry.size.width), id: \.self) { index in
                    //
                    if isUnitVisible(ofIndex: index, withWidth: geometry.size.width) {
                        PreciseUnit2DView(isActive: active, unitHeight: unitHeight(forIndex: index, withFrameSize: geometry.size), hasValue: hasUnitValue(ofIndex: index, withFrameSize: geometry.size), valueLabel: {
                            if hasUnitValue(ofIndex: index, withFrameSize: geometry.size) {
                                        valueLabel?(unitValue(forIndex: index, withWidth: geometry.size.width))
                                            .zIndex(1)
                                    }
                                }
                            )
                            .frame(
                                width: maxLabelWidth(fromHeight: geometry.size.height),
                                height: axisHeight(fromFrameHeight: geometry.size.height)
                            )
                            .offset(
                                x: unitOffset(forIndex: index, withWidth: geometry.size.width)
                            )
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: axisHeight(fromFrameHeight: geometry.size.height),
                    alignment: .center
                )
                //
                
                PreciseUnit2DView(
                    isActive: active,
                    unitHeight: maxUnitHeight(fromHeight: geometry.size.height),
                    hasValue: true,
                    valueLabel: {
                        valueLabel?(maxValue)
                    }
                )
                .frame(
                    width: maxLabelWidth(fromHeight: geometry.size.height),
                    height: axisHeight(fromFrameHeight: geometry.size.height)
                )
                .offset(x: maxBoundaryOffset)
                
                PreciseUnit2DView(
                    isActive: active,
                    unitHeight: maxUnitHeight(fromHeight: geometry.size.height),
                    hasValue: true,
                    valueLabel: {
                        valueLabel?(minValue)
                    }
                )
                .frame(
                    width: maxLabelWidth(fromHeight: geometry.size.height),
                    height: axisHeight(fromFrameHeight: geometry.size.height)
                )
                .offset(x: minBoundaryOffset)
            }
            .clipShape(Rectangle())
        }
    }
    
    private func hasUnitValue(ofIndex index: Int, withFrameSize frame: CGSize) -> Bool {
        (
            truncScale > 4 ||
            relativeIndex(
                forIndex: index,
                withWidth: frame.width
            ) % 5 == 0
        ) &&
        !isUnitOverlapped(ofIndex: index, withFrameSize: frame)
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

    private func maxLabelWidth(fromHeight height: CGFloat) -> CGFloat {
        return designUnit * 4.8
    }
    
    // TODO: Ošetřit dělení nulou
    private var maxBoundaryOffset: CGFloat {
        (maxValue - value) / unit * designUnit
    }
    
    private var minBoundaryOffset: CGFloat {
        (minValue - value) / unit * designUnit
    }
    
    // TODO: Musí se tenhle kód v každém -AxisView opakovat?
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
    
    private var unit: CGFloat {
        defaultStep / scaleBase
    }
    
    // Grafická vzdálenost jedné jednotky
    public var designUnit: CGFloat {
        toDesignBase(value: defaultStep) * truncScale
    }
    
    public func unitOffset(forIndex index: Int, withWidth width: CGFloat) -> CGFloat {
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
    
    private func maxUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfUnits(fromWidth: width)) * designUnit
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
    
    public var offset: CGFloat {
        (value / unit) * designUnit
    }
    
    private func maximumUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfUnits(fromWidth: width)) * designUnit
    }
 
    private func maxUnitHeight(fromHeight height: CGFloat) -> CGFloat {
        active ? axisHeight(fromFrameHeight: height) * 0.6 : axisHeight(fromFrameHeight: height) * 0.8
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
    
    private func axisHeight(fromFrameHeight frame: CGFloat) -> CGFloat {
        if active {
            return frame / 10
        }
        else {
            return frame / 20
        }
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
    
    func unitHeight(forIndex index: Int, withFrameSize frame: CGSize) -> CGFloat {
        maxUnitHeight(fromHeight: frame.height)
        * unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: frame.width))
    }
}

struct PreciseAxis2DView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseAxis2DView(maxValue: 1000, minValue: -1000, value: 900.0, truncScale: 1.2, isInfinite: false, isActive: false, minDesignValue: -350, maxDesignValue: 350, defaultStep: 20, scaleBase: 1.0, valueLabel: { value in
                Text("\(Int(value))")
                .foregroundColor(.white)
                .font(
                    .system(size: 7, design: .rounded)
                )
            }
        )
    }
}
