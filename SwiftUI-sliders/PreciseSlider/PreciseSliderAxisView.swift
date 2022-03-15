//
//  PreciseSliderAxisView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 07.03.2022.
//

import SwiftUI

struct PreciseSliderAxisView: View, Animatable {
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
    let unitSize: CGFloat
    
    init(maxValue: CGFloat, minValue: CGFloat, value: CGFloat, truncScale: CGFloat, isInfinite: Bool, maxDesignValue: CGFloat, minDesignValue: CGFloat, scaleBase: CGFloat, unitSize: CGFloat) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.isInfinite = isInfinite
        self.maxDesignValue = maxDesignValue
        self.minDesignValue = minDesignValue
        self.scaleBase = scaleBase
        self.unitSize = unitSize
    }
    
    // TODO: Vyřešit nekonečnost osy (aktuálně hrozí přetečení relativního indexu)
    // TODO: Při špatně zvoleném kroku chybí poslední jednotka
    // TODO: Používat vlastní GeometryReader nebo si ho nechat předávat od parent View?
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadí
                Rectangle()
                    // TODO: Volitelná barva pozadí
                    .foregroundColor(.black)
                //
                ForEach(0..<numberOfUnits(fromWidth: geometry.size.width), id: \.self) { index in
                    if isUnitVisible(ofIndex: index, withWidth: geometry.size.width)
                    {
                        ZStack {
                            // TODO: Vytáhnout jednotku do vlastního View
                            Rectangle()
                                .frame(width: 1, height: unitHeight(forIndex: index, withFrameSize: geometry.size), alignment: .leading)
                                // TODO: Volitelná barva jednotek
                                .foregroundColor(.white)
                            //
                            unitLabel(forIndex: index, withWidth: geometry.size.width)
                                .background(.black)
                                .font(.system(size:7, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width:
                                        truncScale < 1.15 ?
                                       5 * designUnit :
                                        (truncScale < 3.0 ? designUnit * 2 : designUnit),
                                       height: 15)
                        }.offset(x: normalizedOffset(fromOffset: unitOffset(forIndex: index), withWidth: geometry.size.width))
                    }
                }
                // Středový bod
                Rectangle().frame(width: 1, height: geometry.size.height * 0.8).foregroundColor(.blue)
                
                ZStack {
                    // TODO: Vytáhnout jednotku do vlastního View
                    Rectangle()
                        .frame(width: 1, height: maxUnitHeight(fromHeight: geometry.size.height))
                        .foregroundColor(.white)
                    //
                    Text("\(maxValue)")
                        .background(.black)
                        .font(.system(size:7, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width:
                                truncScale < 1.15 ?
                               5 * designUnit :
                                (truncScale < 3.0 ? designUnit * 2 : designUnit),
                               height: 15)
                }
                .offset(x: maxBoundaryOffset)
                
                ZStack {
                    // TODO: Vytáhnout jednotku do vlastního View
                    Rectangle()
                        .frame(width: 1, height: maxUnitHeight(fromHeight: geometry.size.height))
                        .foregroundColor(.white)
                    //
                    Text("\(minValue)")
                        .background(.black)
                        .font(.system(size:7, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width:
                                truncScale < 1.15 ?
                               5 * designUnit :
                                (truncScale < 3.0 ? designUnit * 2 : designUnit),
                               height: 15)
                }
                .offset(x: minBoundaryOffset)
            }
        }
        .clipShape(Rectangle())
    }
    
    private var maxBoundaryOffset: CGFloat {
        toDesignBase(value: (maxValue - value) / unit * designUnit)
    }
    
    private var minBoundaryOffset: CGFloat {
        toDesignBase(value: (minValue - value) / unit * designUnit)
    }
    
    // TODO: Refactor
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
    
    private func unitOffset(forIndex index: Int) -> CGFloat {
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
    
    public func unitHeightRatio(forIndex index: Int) -> CGFloat {
        if index % 5 != 0 {
            let height = (truncScale - 1) / 3
            return height < 1 ? height : 1
        }
        //
        return 1
    }
    
    private func maxUnitHeight(fromHeight height: CGFloat) -> CGFloat {
        return height / 2
    }
    
    public func unitHeight(forIndex index: Int, withFrameSize frame: CGSize) -> CGFloat {
        let value = unitValue(forIndex: index, withWidth: frame.width)
        
        if value == minValue || value == maxValue {
            return maxUnitHeight(fromHeight: frame.height)
        }
        
        return unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: frame.width)) * maxUnitHeight(fromHeight: frame.height)
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
    
    // TODO: Custom label
    private func unitLabel(forIndex index: Int, withWidth width: CGFloat) -> Text {
        return defaultUnitLabel(forIndex: index, withWidth: width)
    }
    
    public func unitValue(forIndex index: Int, withWidth width: CGFloat) -> Double {
        return (
            (relativeUnit * Double(relativeIndex(forIndex: index, withWidth: width) - middleIndex(fromWidth: width)))
        )
    }
    
    private func defaultUnitLabel(forIndex index: Int, withWidth width: CGFloat) -> Text {
        if truncScale > 3.0 ||
            relativeIndex(forIndex: index, withWidth: width) % 5 == 0 {
            return Text(String(unitValue(forIndex: index, withWidth: width)))
        }
        //
        return Text("")
    }
}

struct PreciseSliderAxisView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderAxisView(maxValue: 150.0, minValue: -150.0, value: 140, truncScale: 1.8, isInfinite: false, maxDesignValue: 350, minDesignValue: -350, scaleBase: 1.0, unitSize: 20)
            .frame(width: 350, height: 50, alignment: .center)
    }
}
