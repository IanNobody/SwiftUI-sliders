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
    let designUnit: CGFloat
    let unit: CGFloat
    let isInfinite: Bool
    
    init(maxValue: CGFloat, minValue: CGFloat, value: CGFloat, truncScale: CGFloat, designUnit: CGFloat, unit: CGFloat, isInfinite: Bool) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.designUnit = designUnit
        self.unit = unit
        self.isInfinite = isInfinite
    }
    
    // TODO: Vyřešit nekonečnost osy (aktuálně hrozí přetečení relativního indexu)
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadí
                Rectangle()
                    // TODO: Volitelná barva pozadí
                    .foregroundColor(.black)
                //
                ForEach(0..<numberOfUnits(fromWidth: geometry.size.width)) { index in
                    ZStack {
                        if isUnitVisible(ofIndex: index, withWidth: geometry.size.width)
                        {
                            Rectangle()
                                .frame(width: 1, height: unitHeight(forIndex: index, withWidth: geometry.size.width), alignment: .leading)
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
                        }
                    }.offset(x: normalizedOffset(fromOffset: unitOffset(forIndex: index), withWidth: geometry.size.width))
                }
                // Středový bod
                Rectangle().frame(width: 1, height: 40).foregroundColor(.blue)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.width / 8
            )
        }
        .clipShape(Rectangle())
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
        
        let indexOffset = index - Int(value / unit)
        
        // Zaokrouhlení k nejbližšímu nižšímu násobku celkového počtu jednotek
        let roundedOffset = Int(floor(
            Float(indexOffset)
            / Float(numberOfUnits(fromWidth: width))
        )) * numberOfUnits(fromWidth: width)

        return index - roundedOffset
    }
    
    public var offset: CGFloat {
        (value / unit) * designUnit
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
    
    private func axisHeight(fromFrameWidth frame: CGFloat) -> CGFloat {
        return frame / 6
    }
    
    private func maxUnitHeight(fromWidth width: CGFloat) -> CGFloat {
        return axisHeight(fromFrameWidth: width) / 2
    }
    
    public func unitHeight(forIndex index: Int, withWidth width: CGFloat) -> CGFloat {
        return unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: width)) * maxUnitHeight(fromWidth: width)
    }
    
    public func isUnitVisible(ofIndex index: Int, withWidth width: CGFloat) -> Bool {
        if (unitValue(forIndex: index, withWidth: width) > maxValue ||
            unitValue(forIndex: index, withWidth: width) < minValue) &&
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
            (unit * Double(relativeIndex(forIndex: index, withWidth: width) - middleIndex(fromWidth: width)))
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
        PreciseSliderAxisView(maxValue: 1000.0, minValue: -1000.0, value: 0, truncScale: 1.0, designUnit: 10.0, unit: 10.0, isInfinite: false)
    }
}
