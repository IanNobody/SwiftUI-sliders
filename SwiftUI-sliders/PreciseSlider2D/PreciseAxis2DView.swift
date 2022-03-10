//
//  PreciseAxisView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 16.02.2022.
//

import SwiftUI

struct PreciseAxis2DView: View, Animatable {
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
    let active: Bool
    
    init(maxValue: CGFloat, minValue: CGFloat, value: CGFloat, truncScale: CGFloat, designUnit: CGFloat, unit: CGFloat, isInfinite: Bool, isActive: Bool) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.designUnit = designUnit
        self.unit = unit
        self.isInfinite = isInfinite
        self.active = isActive
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .frame(
                        width: geometry.size.width,
                        height: axisHeight(
                            fromFrameWidth: geometry.size.width
                        ),
                        alignment: .leading)
                    .foregroundColor(.black)
                //
                ForEach(0..<numberOfUnits(fromWidth: geometry.size.width), id: \.self) { index in
                    //
                    Rectangle()
                        .frame(
                            width: 1,
                            height: unitHeight(forIndex: index, withFrameWidth: geometry.size.width)
                        )
                        .foregroundColor(.white)
                        .offset(
                            x: normalizedOffset(
                                fromOffset: unitOffset(forIndex: index),
                                withWidth: geometry.size.width
                            ),
                            y: active ?
                                // TODO: Má tato konstanta opodstatnění?
                                2.5 :
                                .zero
                        )
                }
                .frame(
                    width: geometry.size.width,
                    height: axisHeight(fromFrameWidth: geometry.size.width),
                    alignment: active ?
                        .top :
                        .center
                )
                //
                Rectangle()
                    .frame(
                        width: 1,
                        height: axisHeight(
                            fromFrameWidth: geometry.size.width
                        ) * 0.8,
                        alignment: .center
                    )
                    // TODO: Nastavitelná barva
                    .foregroundColor(.blue)
            }
        }
    }
    
    // TODO: Musí se tenhle kód v každém -AxisView opakovat?
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
    
    private func maxUnitHeight(fromWidth width: CGFloat) -> CGFloat {
        return axisHeight(fromFrameWidth: width) / 2
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
    
    private func axisHeight(fromFrameWidth frame: CGFloat) -> CGFloat {
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
    
    func unitHeight(forIndex index: Int, withFrameWidth width: CGFloat) -> CGFloat {
        let height = axisHeight(fromFrameWidth: width)
            * unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: width))
            * 0.8
        
        return active ? height/2 : height
    }
}

struct PreciseAxis2DView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseAxis2DView(maxValue: 1000, minValue: -1000, value: 0.0, truncScale: 1.0, designUnit: 10.0, unit: 10.0, isInfinite: false, isActive: false)
    }
}
