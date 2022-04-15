//
//  PreciseSliderAxisView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 07.03.2022.
//

import SwiftUI

struct PreciseAxisView<UnitLabel: View>: View, Animatable {
    @Environment(\.preciseSliderStyle) var style

    //
    let maxValue: CGFloat
    let minValue: CGFloat

    var animatableData: CGFloat
    private var value: CGFloat {
        animatableData
    }

    let truncScale: CGFloat
    let isInfinite: Bool
    let maxDesignValue: CGFloat
    let minDesignValue: CGFloat
    let scaleBase: CGFloat
    let numberOfUnits: Int

    //
    @ViewBuilder let valueLabel: ((_ value: CGFloat, _ stepSize: CGFloat) -> UnitLabel)?

    //
    init(maxValue: CGFloat, minValue: CGFloat, value: CGFloat,
         truncScale: CGFloat, isInfinite: Bool, maxDesignValue: CGFloat,
         minDesignValue: CGFloat, scaleBase: CGFloat, numberOfUnits: Int,
         valueLabel: ((_ value: CGFloat, _ stepSize: CGFloat) -> UnitLabel)?) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.animatableData = value
        self.truncScale = truncScale
        self.isInfinite = isInfinite
        self.maxDesignValue = maxDesignValue
        self.minDesignValue = minDesignValue
        self.scaleBase = scaleBase
        self.numberOfUnits = numberOfUnits
        self.valueLabel = valueLabel
    }

    //
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadí osy
                Rectangle()
                    .foregroundColor(style.backgroundColor)
                // Osa se stupni
                ForEach(0..<numberOfVisibleUnits(fromWidth: geometry.size.width), id: \.self) { index in
                    //
                    if isUnitVisible(ofIndex: index, withWidth: geometry.size.width) {
                        PreciseUnitView(
                            isHighlighted:
                                isUnitHighlited(
                                    ofIndex: index,
                                    withFrameSize: geometry.size
                                ),
                            color:
                                style.unitColor(
                                    unitValue(forIndex: index, withWidth: geometry.size.width),
                                    isUnitHighlited(ofIndex: index, withFrameSize: geometry.size)
                                ),
                            unitLabel: {
                                valueLabel?(
                                    unitValue(
                                        forIndex: index,
                                        withWidth: geometry.size.width
                                    ),
                                    visualStep
                                )
                                .zIndex(1)
                            }
                        )
                        .frame(
                            width: maxLabelWidth(fromHeight: geometry.size.height),
                            height: unitHeight(forIndex: index, withFrameSize: geometry.size)
                        )
                        .offset(
                            x: unitOffset(forIndex: index, withWidth: geometry.size.width)
                        )
                    }
                }

                // Středový ukazatel
                Rectangle()
                    .frame(width: 1, height: geometry.size.height * 0.8)
                    .foregroundColor(style.axisPointerColor)
            }
            .drawingGroup()
        }
        .clipShape(Rectangle())
    }

    // Vzdálenost mezi vyznačenými jednotkami
    private var visualStep: CGFloat {
        truncScale > 3 ? scaledUnitValue : 5 * scaledUnitValue
    }

    private func isUnitHighlited(ofIndex index: Int, withFrameSize frame: CGSize) -> Bool {
        (
            truncScale > 3.0
            || relativeIndex(forIndex: index, withWidth: frame.width) % 5 == 0
        )
    }

    private func maxLabelWidth(fromHeight height: CGFloat) -> CGFloat {
        let minUnitHeight = minUnitHeightRatio * maxUnitHeight(fromHeight: height)

        // 1/3 = minimální viditelný rozměr jednotky
        if minUnitHeight > (1/3) {
            return truncScale < 3 ?
                unitSize * 1.8 : unitSize * 0.8
        }
        else {
            return unitSize * 4.8
        }
    }

    private func maxLabelHeight(fromHeight height: CGFloat) -> CGFloat {
        maxUnitHeight(fromHeight: height) / 3
    }

    private func toDesignBase(value: CGFloat) -> CGFloat {
        let valueRange = (maxValue - minValue)
        let designRange = (maxDesignValue - minDesignValue)

        if valueRange != 0 {
            return value * designRange / valueRange
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
    public var scaledUnitValue: CGFloat {
        let scaleBase = scaleBase > 0 ? scaleBase : 1
        return defaultUnitValue / scaleBase
    }

    // Vizuální rozměr jedné jednotky
    public var unitSize: CGFloat {
        toDesignBase(value: defaultUnitValue) * truncScale
    }

    private func unitOffset(forIndex index: Int, withWidth width: CGFloat) -> CGFloat {
        var offset = (CGFloat(index) * unitSize) - offset
        let max = maxUnitOffset(fromWidth: width)
        let middleIndexOffset = unitSize * CGFloat(middleIndex(fromWidth: width))

        if offset > max {
            offset = offset.truncatingRemainder(dividingBy: max)
        }
        else if offset < 0 {
            offset = max + offset.truncatingRemainder(dividingBy: max)
        }

        // Korekce posunu jednotky o polovinu osy
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
        return base * 5
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
        let numberOfRotations = Int(
            floor(
                Float(abs(indexOffset))
                / Float(numberOfVisibleUnits(fromWidth: width))
            )
        )

        // Korekce zaokrouhlení pro záporná čísla
        if indexOffset < 0 {
            return index
                + (numberOfRotations + 1)
                * numberOfVisibleUnits(fromWidth: width)
                - middleIndex(fromWidth: width)
        }

        return index
            - (numberOfRotations * (numberOfVisibleUnits(fromWidth: width)))
            - middleIndex(fromWidth: width)
    }

    // Posun celé osy vzhledem k vybrané aktuální hodnotě
    public var offset: CGFloat {
        if scaledUnitValue == 0 {
            return 0
        }

        return (value / scaledUnitValue) * unitSize
    }

    private func maxUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfVisibleUnits(fromWidth: width)) * unitSize
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
        unitHeightRatio(
            forIndex: relativeIndex(forIndex: index, withWidth: frame.width)
        ) * maxUnitHeight(fromHeight: frame.height)
    }

    private var isReversed: Bool {
        maxValue < minValue
    }

    public func isUnitVisible(ofIndex index: Int, withWidth width: CGFloat) -> Bool {
        let minValue = isReversed ? self.maxValue : self.minValue
        let maxValue = isReversed ? self.minValue : self.maxValue

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
        let minValue = isReversed ? self.maxValue : self.minValue
        let maxValue = isReversed ? self.minValue : self.maxValue
        var value = scaledUnitValue * Double(relativeIndex(forIndex: index, withWidth: width))

        if isInfinite && value > maxValue {
            value = (value - minValue).truncatingRemainder(dividingBy: (maxValue - minValue)) + minValue
        }

        if isInfinite && value < minValue {
            value = (value - minValue).truncatingRemainder(dividingBy: (maxValue - minValue)) + maxValue
        }

        return value
    }
}

struct PreciseAxisView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseAxisView(
            maxValue: 200.0,
            minValue: -200.0,
            value: 13,
            truncScale: 1,
            isInfinite: true,
            maxDesignValue: 300,
            minDesignValue: -300,
            scaleBase: 1.0,
            numberOfUnits: 20,
            valueLabel: { value, _ in
                Text("\(value)")
                    .background(.black)
                    .font(.system(size: 7, design: .rounded))
                    .foregroundColor(.white)
            }
        )
        .frame(width: 300, height: 50, alignment: .center)
    }
}
