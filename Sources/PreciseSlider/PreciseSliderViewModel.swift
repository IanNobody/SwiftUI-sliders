//
//  PreciseSliderViewModel.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 11.02.2022.
//

import Foundation
import SwiftUI
import Combine

open class PreciseSliderViewModel: ObservableObject {
    @Published public private(set) var unsafeValue: Double {
        didSet {
            valuePublisher.send(value)
        }
    }
    @Published public private(set) var scale: Double
    @Published public private(set) var isEditing: Bool = false

    //

    public var prevValue: Double
    public var prevScale: Double

    public var minValue: Double
    public var maxValue: Double

    public var minScale: Double
    public var maxScale: Double

    public var numberOfUnits: Int
    public var isInfinite: Bool

    //

    public init(
        defaultValue: Double = Double.zero,
        defaultScale: Double = 1.0,
        minValue: Double = 0,
        maxValue: Double = 100,
        minScale: Double = 1.0,
        maxScale: Double = .infinity,
        numberOfUnits: Int = 20,
        isInfinite: Bool = false
    ) {
        self.unsafeValue = defaultValue
        self.prevValue = defaultValue
        self.scale = defaultScale
        self.prevScale = defaultScale
        self.minValue = minValue
        self.maxValue = maxValue
        self.minScale = minScale < maxScale ? minScale : maxScale
        self.maxScale = maxScale > minScale ? maxScale : minScale
        self.numberOfUnits = numberOfUnits * 5
        self.isInfinite = isInfinite
    }

    private var correctMinValue: Double {
        isReversed ? maxValue : minValue
    }

    private var correctMaxValue: Double {
        isReversed ? minValue : maxValue
    }

    public var defaultValue: Double {
        get {
            value
        }
        set {
            move(toValue: newValue)
            prevValue = newValue
        }
    }

    public var defaultScale: Double {
        get {
            scale
        }
        set {
            zoom(toValue: newValue)
            prevScale = newValue
        }
    }

    public var isReversed: Bool {
        maxValue < minValue
    }

    public var value: Double {
        if unsafeValue > correctMaxValue || unsafeValue < correctMinValue {
            if isInfinite {
                let relativeValue = (unsafeValue - correctMinValue)
                    .truncatingRemainder(dividingBy: (correctMaxValue - correctMinValue))
                return relativeValue > 0 ? relativeValue + correctMinValue : relativeValue + correctMaxValue
            }
            else {
                return unsafeValue > correctMaxValue ? correctMaxValue : correctMinValue
            }
        }

        return unsafeValue
    }

    public let valuePublisher = PassthroughSubject<Double, Never>()

    public var scaleBase: Double {
        let exponent = floor(log(scale) / log(5))
        return pow(5, exponent)
    }

    public var truncScale: Double {
        scale / scaleBase
    }

    //

    public func move(byValue difference: CGFloat) {
        var newValue = prevValue - (difference / scale)

        if newValue > correctMaxValue || newValue < correctMinValue {
            if !isInfinite {
                let unscaledNewValue = prevValue - difference
                let difference = unscaledNewValue -
                    (unscaledNewValue > correctMaxValue ?
                        correctMaxValue : correctMinValue)

                newValue = newValue > correctMaxValue ?
                    correctMaxValue + ((pow(abs(difference) + 1/4, 1/2) - 1/2) / scale) :
                    correctMinValue - ((pow(abs(difference) + 1/4, 1/2) - 1/2) / scale)
            }
            else {
                if newValue > correctMaxValue {
                    newValue = correctMinValue + (newValue - correctMinValue)
                            .truncatingRemainder(dividingBy: (correctMinValue - correctMaxValue))
                }
                else {
                    newValue = correctMaxValue + (newValue - correctMinValue)
                            .truncatingRemainder(dividingBy: (correctMinValue - correctMaxValue))
                }
            }
        }

        unsafeValue = newValue
        isEditing = true
    }

    public func move(toValue newValue: CGFloat) {
        if unsafeValue > correctMaxValue || unsafeValue < correctMinValue {
            if isInfinite {
                let relativeValue = (newValue - correctMinValue)
                    .truncatingRemainder(dividingBy: (correctMaxValue - correctMinValue))
                unsafeValue = relativeValue > 0 ? relativeValue + correctMinValue : relativeValue + correctMaxValue
            }
            else {
                unsafeValue = newValue > correctMaxValue ? correctMaxValue : correctMinValue
            }
        }
        else {
            unsafeValue = newValue
        }

        prevValue = unsafeValue
    }

    public func zoom(byValue difference: CGFloat) {
        var newScale = prevScale * difference

        if newScale > maxScale {
           newScale = maxScale
        }

        if newScale < minScale {
            newScale = minScale
        }

        scale = newScale
    }

    public func zoom(toValue newScale: CGFloat) {
        if newScale > maxScale {
            scale = maxScale
        }
        else if newScale < minScale {
            scale = minScale
        }
        else {
            scale = newScale
        }

        prevScale = scale
    }

    func animateOutsideHardBounds(to newValue: CGFloat, by difference: CGFloat, with duration: CGFloat) {
        if unsafeValue > correctMinValue && unsafeValue < correctMaxValue
                && !isInfinite {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75, blendDuration: 0.0)) {
                unsafeValue = newValue > correctMaxValue ? correctMaxValue : correctMinValue
                prevValue = newValue > correctMaxValue ? correctMaxValue : correctMinValue
            }
        }
        else {
            withAnimation(.spring()) {
                unsafeValue = unsafeValue > correctMaxValue ? correctMaxValue : correctMinValue
                prevValue = unsafeValue > correctMaxValue ? correctMaxValue : correctMinValue
            }
        }
    }

    func animateOutsideSoftBounds(to newValue: CGFloat, with duration: CGFloat) {
        withAnimation(.easeOut(duration: duration)) {
            unsafeValue = newValue
            prevValue = newValue
        }
    }

    open func animateMomentum(byValue difference: CGFloat,
                              translationCoefitient coefitient: Double,
                              duration: CGFloat) {
        let newValue = unsafeValue - ((difference * coefitient) / scale)

        if difference <= 5  && newValue > correctMinValue && newValue < correctMaxValue {
            return
        }

        // Zastavení probíhajících animací
        withAnimation(.linear(duration: 0)) {
            unsafeValue = unsafeValue
            prevValue = unsafeValue
        }

        if unsafeValue > correctMinValue && unsafeValue < correctMaxValue &&
            newValue > correctMinValue && newValue < correctMaxValue {
            withAnimation(.easeOut(duration: duration)) {
                unsafeValue = newValue
                prevValue = newValue
            }
        }
        else {
            if isInfinite {
                animateOutsideSoftBounds(to: newValue, with: duration)
            }
            else {
                animateOutsideHardBounds(to: newValue, by: (difference * coefitient), with: duration)
            }
        }
    }

    //

    open func editingValueEnded() {
        prevValue = unsafeValue
        isEditing = false
    }

    public func editingScaleEnded() {
        prevScale = scale
    }
}
