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
    let unitSize: CGFloat
    let scaleBase: CGFloat
    let truncScale: CGFloat
    let isInfinite: Bool
    let active: Bool
    
    @ViewBuilder let valueLabel: ((_ forValue: Double) -> ValueLabel)?
    
    init(maxValue: CGFloat, minValue: CGFloat, value: CGFloat, truncScale: CGFloat, isInfinite: Bool, isActive: Bool, minDesignValue: CGFloat, maxDesignValue: CGFloat, unitSize: CGFloat, scaleBase: CGFloat, valueLabel: ((_ forValue: Double) -> ValueLabel)?) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.isInfinite = isInfinite
        self.active = isActive
        self.minDesignValue = minDesignValue
        self.maxDesignValue = maxDesignValue
        self.scaleBase = scaleBase
        self.unitSize = unitSize
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
                        ZStack {
                            VStack {
                                Rectangle()
                                    .frame(
                                        width: 1,
                                        height: unitHeight(forIndex: index, withFrameSize: geometry.size)
                                    )
                                    .foregroundColor(.white)
                                if active && relativeIndex(forIndex: index, withWidth: geometry.size.width) % 5 == 0 {
                                    valueLabel?(unitValue(forIndex: index, withWidth: geometry.size.width))
                                    .frame(
                                        width:
                                            truncScale < 1.15 ?
                                                5 * designUnit :
                                                (
                                                    truncScale < 3.0 ?
                                                    designUnit * 2 :       designUnit
                                                ),
                                        height:
                                            axisHeight(
                                                fromFrameHeight: geometry.size.height
                                            )
                                            - unitHeight(
                                                forIndex: index,
                                                withFrameSize:  geometry.size
                                            ),
                                        alignment: .top
                                    )
                                }
                            }
                        }
                        .offset(
                            x: normalizedOffset(
                                fromOffset:        unitOffset(forIndex: index),
                                withWidth: geometry.size.width
                            ),
                            y: active ?
                            // TODO: Má tato konstanta opodstatnění?
                                2.5 :
                                    .zero
                        )
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: axisHeight(fromFrameHeight: geometry.size.height),
                    alignment: active ?
                        .top :
                        .center
                )
                //
                Rectangle()
                    .frame(
                        width: 1,
                        height: axisHeight(
                            fromFrameHeight: geometry.size.height
                        ) * 0.8,
                        alignment: .center
                    )
                    // TODO: Nastavitelná barva
                    .foregroundColor(.blue)
                
                
                ZStack {
                    VStack {
                        Rectangle()
                            .frame(
                                width: 1,
                                height: maxUnitHeight(fromHeight: geometry.size.height)
                            )
                            .foregroundColor(.white)
                        
                        if active {
                            valueLabel?(maxValue)
                            .frame(
                                width:
                                    truncScale < 1.15 ?
                                        5 * designUnit :
                                        (
                                            truncScale < 3.0 ?
                                            designUnit * 2 :       designUnit
                                        ),
                                    height:
                                        axisHeight(
                                            fromFrameHeight: geometry.size.height
                                        )
                                        - maxUnitHeight(fromHeight: geometry.size.height),
                                    alignment: .top
                                )
                        }
                    }
                    .offset(
                        x: maxBoundaryOffset,
                        y: active ?
                        // TODO: Má tato konstanta opodstatnění?
                        2.5 :
                        .zero
                    )
                
                    VStack {
                        Rectangle()
                            .frame(
                                width: 1,
                                height: maxUnitHeight(fromHeight: geometry.size.height)
                            )
                            .foregroundColor(.white)
                        
                        if active {
                            valueLabel?(minValue)
                            .frame(
                                width:
                                    truncScale < 1.15 ?
                                        5 * designUnit :
                                        (
                                            truncScale < 3.0 ?
                                            designUnit * 2 :       designUnit
                                        ),
                                    height:
                                        axisHeight(
                                            fromFrameHeight: geometry.size.height
                                        )
                                        - maxUnitHeight(fromHeight: geometry.size.height),
                                    alignment: .top
                                )
                        }
                    }
                    .offset(
                        x: minBoundaryOffset,
                        y: active ?
                        // TODO: Má tato konstanta opodstatnění?
                        2.5 :
                                .zero
                    )
                }
                .frame(
                    width: geometry.size.width,
                    height: axisHeight(fromFrameHeight: geometry.size.height),
                    alignment: active ?
                        .top :
                        .center
                )
            }
            .clipShape(Rectangle())
        }
    }
    
    // TODO: Ošetřit dělení nulou
    private var maxBoundaryOffset: CGFloat {
        toDesignBase(value: (maxValue - value) / unit * designUnit)
    }
    
    private var minBoundaryOffset: CGFloat {
        toDesignBase(value: (minValue - value) / unit * designUnit)
    }
    
    // TODO: Musí se tenhle kód v každém -AxisView opakovat?
    private func toDesignBase(value: CGFloat) -> CGFloat {
        value * (maxDesignValue - minDesignValue) / (maxValue - minValue)
    }
    
    private func toRealBase(value: CGFloat) -> CGFloat {
        value * (maxValue - minValue) / (maxDesignValue - minDesignValue)
    }
    
    private var relativeUnit: CGFloat {
        toRealBase(value: unit)
    }
    
    private var relativeValue: CGFloat {
        toRealBase(value: value)
    }
    
    var defaultStep: CGFloat {
        return toDesignBase(value: (unitSize / 5))
    }
    
    // Reálná hodnota zobrazené jednotky
    public var unit: CGFloat {
        Double(defaultStep) / scaleBase
    }
    
    // Grafická vzdálenost jedné jednotky
    public var designUnit: CGFloat {
        CGFloat(defaultStep) * truncScale
    }
    
    public func unitOffset(forIndex index: Int) -> CGFloat {
        let offset = (
            (CGFloat(index) * designUnit)
            - offset
        )
        
        return offset
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
    
    // Index jednotky s ohledem na zvolenou hodnotu
    public func relativeIndex(forIndex index: Int, withWidth width: CGFloat) -> Int {
        
        let indexOffset = index - Int(value / relativeUnit)
        
        // Zaokrouhlení k nejbližšímu nižšímu násobku celkového počtu jednotek
        let roundedOffset = Int(floor(
            Float(indexOffset)
            / Float(numberOfUnits(fromWidth: width))
        )) * numberOfUnits(fromWidth: width)

        return index - roundedOffset
    }
    
    public var offset: CGFloat {
        toDesignBase(value: ((value / unit) * designUnit))
    }
    
    private func maximumUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfUnits(fromWidth: width)) * designUnit
    }
    
    private func normalizedOffset(fromOffset offset: CGFloat, withWidth width: CGFloat) -> CGFloat {
        let max = maximumUnitOffset(fromWidth: width)
        
        let scaleCorrection = designUnit * CGFloat(middleIndex(fromWidth: width))
        
        if offset > max {
            return (offset.truncatingRemainder(dividingBy: max) - scaleCorrection)
        }
        
        if offset < 0 {
            return max + (offset.truncatingRemainder(dividingBy: max) - scaleCorrection)
        }
        
        return (offset - scaleCorrection)
    }
    
    private func maxUnitHeight(fromHeight height: CGFloat) -> CGFloat {
        active ? axisHeight(fromFrameHeight: height) * 0.4 : axisHeight(fromFrameHeight: height) * 0.8
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
        return (
            (relativeUnit * Double(relativeIndex(forIndex: index, withWidth: width) - middleIndex(fromWidth: width)))
        )
    }
    
    private func axisHeight(fromFrameHeight frame: CGFloat) -> CGFloat {
        if active {
            return frame / 10
        }
        else {
            return frame / 20
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
    
    func unitHeight(forIndex index: Int, withFrameSize frame: CGSize) -> CGFloat {
        maxUnitHeight(fromHeight: frame.height)
        * unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: frame.width))
    }
}

struct PreciseAxis2DView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseAxis2DView(maxValue: 1000, minValue: -1000, value: 900.0, truncScale: 1.0, isInfinite: false, isActive: true, minDesignValue: -350, maxDesignValue: 350, unitSize: 100, scaleBase: 1.0, valueLabel: { value in
                Text("\(Int(value))")
                .foregroundColor(.white)
                .font(
                    .system(size: 7, design: .rounded)
                )
            }
        )
    }
}
