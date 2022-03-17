//
//  PreciseSliderAxisView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 07.03.2022.
//

import SwiftUI

struct PreciseSliderAxisView<UnitLabel: View>: View, Animatable {
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
    let defaultStep: CGFloat
    
    @ViewBuilder let valueLabel: ((_ value: CGFloat) -> UnitLabel)?
    
    init(maxValue: CGFloat, minValue: CGFloat, value: CGFloat, truncScale: CGFloat, isInfinite: Bool, maxDesignValue: CGFloat, minDesignValue: CGFloat, scaleBase: CGFloat, defaultStep: CGFloat, valueLabel: ((_ value: CGFloat) -> UnitLabel)?) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.isInfinite = isInfinite
        self.maxDesignValue = maxDesignValue
        self.minDesignValue = minDesignValue
        self.scaleBase = scaleBase
        self.defaultStep = defaultStep
        self.valueLabel = valueLabel
    }
    
    // TODO: Vyřešit nekonečnost osy (aktuálně hrozí přetečení relativního indexu)
    // TODO: Používat vlastní GeometryReader nebo si ho nechat předávat od parent View?
    // TODO: Volitelné barvy
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadí
                Rectangle()
                    .foregroundColor(.black)
                //
                ForEach(0..<numberOfUnits(fromWidth: geometry.size.width), id: \.self) { index in
                    if isUnitVisible(ofIndex: index, withWidth: geometry.size.width)
                    {
                        PreciseSliderUnitView {
                            if truncScale > 3.0 ||
                                relativeIndex(forIndex: index, withWidth: geometry.size.width) % 5 == 0 {
                                valueLabel?(unitValue(forIndex: index, withWidth: geometry.size.width))
                            }
                        }
                        .frame(width: maxLabelWidth, height: unitHeight(forIndex: index, withFrameSize: geometry.size))
                        .offset(
                            x: unitOffset(forIndex: index, withWidth: geometry.size.width))
                    }
                }
                // Středový bod
                Rectangle().frame(width: 1, height: geometry.size.height * 0.8).foregroundColor(.blue)
                
                // TODO: Při špatně zvoleném kroku text poslední jednotky překrývá ty předchozí.
                // Zobrazení jednotky minimální hodnoty
                PreciseSliderUnitView {
                    valueLabel?(minValue)
                }
                .frame(
                    width: maxLabelWidth,
                    height: maxUnitHeight(fromHeight: geometry.size.height)
                )
                .offset(x: minBoundaryOffset)
                
                // Zobrazení jednotky maximální hodnoty
                PreciseSliderUnitView {
                    valueLabel?(maxValue)
                }
                .frame(
                    width: maxLabelWidth,
                    height: maxUnitHeight(fromHeight: geometry.size.height)
                )
                .offset(x: maxBoundaryOffset)
            }
        }
        .clipShape(Rectangle())
    }
    
    private var maxLabelWidth: CGFloat {
        truncScale < 1.15 ?
            (4.8 * designUnit) :
            (truncScale < 3.0 ?
                (designUnit * 1.8) :
                (designUnit * 0.8))
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
        let indexOffset = index - Int(value / unit) - 1
        
        // Zaokrouhlení k nejbližšímu nižšímu násobku celkového počtu jednotek
        let roundedOffset = Int(floor(
            Float(indexOffset)
            / Float(numberOfUnits(fromWidth: width))
        )) * numberOfUnits(fromWidth: width)

        return index - middleIndex(fromWidth: width) - roundedOffset
    }
    
    // Posun osy dle vybrané hodnoty
    public var offset: CGFloat {
        (value / unit) * designUnit
    }
    
    private func maxUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfUnits(fromWidth: width)) * designUnit
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
        unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: frame.width)) * maxUnitHeight(fromHeight: frame.height)
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

struct PreciseSliderAxisView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderAxisView(maxValue: 200.0, minValue: -200.0, value: 0, truncScale: 1, isInfinite: false, maxDesignValue: 300, minDesignValue: -300, scaleBase: 1.0, defaultStep: 4, valueLabel: { value in
                Text("\(value)")
                    .background(.black)
                    .font(.system(size:7, design: .rounded))
                    .foregroundColor(.white)
            }
        )
        .frame(width: 300, height: 50, alignment: .center)
    }
}
