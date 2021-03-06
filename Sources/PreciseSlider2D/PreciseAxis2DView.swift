//
//  PreciseAxisView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 16.02.2022.
//

import SwiftUI

struct PreciseAxis2DView<ValueLabel: View>: View, Animatable {
    @Environment(\.preciseSlider2DStyle) var style

    //
    let maxValue: CGFloat
    let minValue: CGFloat

    var animatableData: CGFloat
    var value: CGFloat {
        animatableData
    }

    let minDesignValue: CGFloat
    let maxDesignValue: CGFloat
    let numberOfUnits: Int
    let scaleBase: CGFloat
    let truncScale: CGFloat
    let isInfinite: Bool
    let active: Bool

    //
    @ViewBuilder let valueLabel: ((_ forValue: Double, _ withStepSize: Double) -> ValueLabel)?

    //
    init(maxValue: CGFloat,
         minValue: CGFloat,
         value: CGFloat,
         truncScale: CGFloat,
         isInfinite: Bool,
         isActive: Bool,
         minDesignValue: CGFloat,
         maxDesignValue: CGFloat,
         numberOfUnits: Int,
         scaleBase: CGFloat,
         valueLabel: ((_ forValue: Double, _ withStep: Double) -> ValueLabel)?) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.isInfinite = isInfinite
        self.active = isActive
        self.minDesignValue = minDesignValue
        self.maxDesignValue = maxDesignValue
        self.scaleBase = scaleBase
        self.numberOfUnits = numberOfUnits
        self.valueLabel = valueLabel
    }

    //
    var body: some View {
        GeometryReader { geometry in
            // Průhledná plocha pro interakci pomocí gest
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
            ZStack {
                // Pozadí osy
                Rectangle()
                    .frame(
                        width: geometry.size.width,
                        height: axisHeight(
                            fromFrameHeight: geometry.size.height
                        ),
                        alignment: .leading)
                    .foregroundColor(style.axisBackgroundColor)
                // Osa se stupni
                ForEach(0..<numberOfVisibleUnits(fromWidth: geometry.size.width), id: \.self) { index in
                    //
                    if isUnitVisible(ofIndex: index, withWidth: geometry.size.width) {
                        PreciseUnit2DView(
                            isActive: active,
                            unitHeight: unitHeight(
                                forIndex: index,
                                withFrameSize: geometry.size
                            ),
                            isHighlited:
                                isUnitHighlighted(
                                    ofIndex: index,
                                    withFrameSize: geometry.size
                                ),
                            color:
                                style.unitColor(
                                    unitValue(
                                        forIndex: index,
                                        withWidth: geometry.size.width
                                    ),
                                    isUnitHighlighted(
                                        ofIndex: index,
                                        withFrameSize: geometry.size
                                    )
                                ),
                            valueLabel: {
                                valueLabel?(unitValue(forIndex: index, withWidth: geometry.size.width), scaledUnitValue)
                                    .zIndex(1)
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

                // Středový ukazatel
                Rectangle()
                    .frame(
                        width: 1,
                        height: axisHeight(fromFrameHeight: geometry.size.height)
                    )
                    .foregroundColor(style.axisPointerColor)
            }
            .drawingGroup()
            .clipShape(Rectangle())
        }
    }

    private func isUnitHighlighted(ofIndex index: Int, withFrameSize frame: CGSize) -> Bool {
        (
            truncScale > 4 ||
            relativeIndex(
                forIndex: index,
                withWidth: frame.width
            ) % 5 == 0
        )
    }

    private func maxLabelWidth(fromHeight height: CGFloat) -> CGFloat {
        return unitSize * 4.8
    }

    private func toDesignBase(value: CGFloat) -> CGFloat {
        let valueRange = (maxValue - minValue)

        if valueRange != 0 {
            return value * (maxDesignValue - minDesignValue) / valueRange
        }
        else {
            return 0
        }
    }

    // Výchozí hodnota jednotky bez aplikace měřítka
    public var defaultUnitValue: CGFloat {
        let numberOfUnits = numberOfUnits > 0 ? numberOfUnits : 20
        return (maxValue - minValue) / CGFloat(numberOfUnits)
    }

    // Hodnota jednotky s aplikací měřítka
    private var scaledUnitValue: CGFloat {
        let scaleBase = scaleBase > 0 ? scaleBase : 1
        return defaultUnitValue / scaleBase
    }

    // Vizuální rozměr jedné jednotky
    public var unitSize: CGFloat {
        toDesignBase(value: defaultUnitValue) * truncScale
    }

    public func unitOffset(forIndex index: Int, withWidth width: CGFloat) -> CGFloat {
        var offset = (CGFloat(index) * unitSize) - offset
        let max = maxUnitOffset(fromWidth: width)
        let middleIndexOffset = unitSize * CGFloat(middleIndex(fromWidth: width))

        if offset > max {
            offset = offset.truncatingRemainder(dividingBy: max)
        }
        else if offset < 0 {
            offset = max + offset.truncatingRemainder(dividingBy: max)
        }

        return (offset - middleIndexOffset)
    }

    private func numberOfVisibleUnits(fromWidth width: CGFloat) -> Int {
        if unitSize == 0 {
            return 0
        }

        let num = Int(ceil(width / CGFloat(unitSize)))

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

    private func maxUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfVisibleUnits(fromWidth: width)) * unitSize
    }

    private func middleIndex(fromWidth width: CGFloat) -> Int {
        return Int(numberOfVisibleUnits(fromWidth: width) / 2)
    }

    // Unikátní index každé jednotky
    public func relativeIndex(forIndex index: Int, withWidth width: CGFloat) -> Int {
        if scaledUnitValue == 0 || numberOfVisibleUnits(fromWidth: width) <= 0 {
            return 0
        }

        let indexOffset = index - Int(ceil(value / scaledUnitValue))
        let offsetRate = Int(floor(Float(abs(indexOffset)) / Float(numberOfVisibleUnits(fromWidth: width))))

        // Korekce zaokrouhlení pro záporná čísla
        if indexOffset < 0 {
            return index + (offsetRate + 1) * (numberOfVisibleUnits(fromWidth: width)) - middleIndex(fromWidth: width)
        }

        return index - (offsetRate * (numberOfVisibleUnits(fromWidth: width))) - middleIndex(fromWidth: width)
    }

    // Posun celé osy vzhledem k vybrané aktuální hodnotě
    public var offset: CGFloat {
        if scaledUnitValue == 0 {
            return 0
        }

        return (value / scaledUnitValue) * unitSize
    }

    private func maxUnitHeight(fromHeight height: CGFloat) -> CGFloat {
        active ?
            axisHeight(fromFrameHeight: height) * 0.6
            : axisHeight(fromFrameHeight: height) * 0.8
    }

    private var isReversed: Bool {
        maxValue < minValue
    }

    public func isUnitVisible(ofIndex index: Int, withWidth width: CGFloat) -> Bool {
        let maxValue = isReversed ? self.minValue : self.maxValue
        let minValue = isReversed ? self.maxValue : self.minValue

        if (unitValue(forIndex: index, withWidth: width) > maxValue ||
            unitValue(forIndex: index, withWidth: width) < minValue) &&
            !isInfinite {
            return false
        }
        else {
            return true
        }
    }

    public func unitValue(forIndex index: Int, withWidth width: CGFloat) -> Double {
        let maxValue = isReversed ? self.minValue : self.maxValue
        let minValue = isReversed ? self.maxValue : self.minValue
        var value = scaledUnitValue * Double(relativeIndex(forIndex: index, withWidth: width))

        if isInfinite && value > maxValue {
            value = (value - minValue).truncatingRemainder(dividingBy: (maxValue - minValue)) + minValue
        }

        if isInfinite && value < minValue {
            value = (value - minValue).truncatingRemainder(dividingBy: (maxValue - minValue)) + maxValue
        }

        return value
    }

    private func axisHeight(fromFrameHeight frame: CGFloat) -> CGFloat {
        active ? frame : frame / 2
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
        * unitHeightRatio(
            forIndex: relativeIndex(
                forIndex: index,
                withWidth: frame.width
            )
        )
    }
}

struct PreciseAxis2DView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseAxis2DView(
            maxValue: 1000,
            minValue: -1000,
            value: 900.0,
            truncScale: 1.2,
            isInfinite: false,
            isActive: false,
            minDesignValue: -350,
            maxDesignValue: 350,
            numberOfUnits: 20,
            scaleBase: 1.0,
            valueLabel: { value, _ in
                Text("\(Int(value))")
                .foregroundColor(.white)
                .font(
                    .system(size: 7, design: .rounded)
                )
            }
        )
        .frame(height: 50)
    }
}
