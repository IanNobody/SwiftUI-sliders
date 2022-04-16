//
//  PreciseSlider.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 01.02.2022.
//

import SwiftUI

public struct PreciseSliderView<ValueLabel: View>: View {
    @ObservedObject public var viewModel: PreciseSliderViewModel
    @ViewBuilder public var valueLabel: (_ value: CGFloat, _ stepSize: CGFloat) -> ValueLabel?

    @GestureState private var dragGestureState: DragGesture.Value?
    @State private var momentum: CGFloat = .zero

    @GestureState private var zoomGestureState: CGFloat = .zero

    //
    public init(viewModel: PreciseSliderViewModel,
                valueLabel: @escaping (_ value: CGFloat, _ stepSize: CGFloat) -> ValueLabel?) {
        self.viewModel = viewModel
        self.valueLabel = valueLabel
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                PreciseAxisView(
                    maxValue: viewModel.maxValue,
                    minValue: viewModel.minValue,
                    value: viewModel.unsafeValue,
                    truncScale: viewModel.truncScale,
                    isInfinite: viewModel.isInfinite,
                    maxDesignValue: maxDesignValue(fromWidth: geometry.size.width),
                    minDesignValue: minDesignValue(fromWidth: geometry.size.width),
                    scaleBase: viewModel.scaleBase,
                    numberOfUnits: viewModel.numberOfUnits,
                    valueLabel: valueLabel
                )
            }
            // Výběr hodnoty
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragGestureState) { actState, prevState, _ in
                        prevState = actState
                    }
            )
            // Výběr měřítka
            .gesture(
                MagnificationGesture(minimumScaleDelta: 0)
                    .updating($zoomGestureState) { gesture, state, _ in
                        state = gesture
                    }
            )
            .onChange(of: dragGestureState) { gesture in
                if let gesture = gesture {
                    if gesture.translation.width != 0 {
                        viewModel.move(
                            byValue: gesture.translation.width
                            * gestureCoefitient(fromWidth: geometry.size.width)
                        )
                    }
                    //
                    momentum = (gesture.predictedEndTranslation.width - gesture.translation.width)
                }
                else {
                    viewModel.animateMomentum(
                        byValue: momentum,
                        translationCoefitient: gestureCoefitient(fromWidth: geometry.size.width),
                        duration: 0.5
                    )

                    viewModel.editingValueEnded()
                }
            }
            .onChange(of: zoomGestureState) { value in
                if value != .zero {
                    viewModel.zoom(byValue: value)
                }
                else {
                    viewModel.editingScaleEnded()
                }
            }
        }
    }

    private func maxDesignValue(fromWidth width: CGFloat) -> CGFloat {
        return width
    }

    private func minDesignValue(fromWidth width: CGFloat) -> CGFloat {
        return -width
    }

    private func gestureCoefitient(fromWidth width: CGFloat) -> CGFloat {
        let designRange = maxDesignValue(fromWidth: width) - minDesignValue(fromWidth: width)

        if designRange > 0 {
            return (viewModel.maxValue - viewModel.minValue) / designRange
        }
        else {
            return 0
        }
    }
}

struct PreciseSliderView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderView(
            viewModel: PreciseSliderViewModel(isInfinite: true),
            valueLabel: { value, _ in
                Text("\(value)")
                    .background(.black)
                    .font(.system(size: 7, design: .rounded))
                    .foregroundColor(.white)
            }
        )
        .frame(width: 350, height: 50, alignment: .center)
    }
}
