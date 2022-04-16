//
//  PreciseSlider2D.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 15.02.2022.
//

import SwiftUI

public struct PreciseSlider2DView<Content: View, AxisXLabel: View, AxisYLabel: View>: View {
    @Environment(\.preciseSlider2DStyle) var style

    //
    @ObservedObject var axisX: PreciseAxis2DViewModel
    @ObservedObject var axisY: PreciseAxis2DViewModel

    //
    @ViewBuilder let content: (_ size: CGSize, _ scale: CGSize) -> Content
    @ViewBuilder let axisXLabel: (_ value: Double, _ step: Double) -> AxisXLabel
    @ViewBuilder let axisYLabel: (_ value: Double, _ step: Double) -> AxisYLabel

    //
    @GestureState var contentDragGestureState: DragGesture.Value?
    @GestureState var contentZoomGestureState: CGFloat = .zero

    @GestureState var axisXDragGestureState: DragGesture.Value?
    @State var axisXMomentum: CGFloat = .zero
    @GestureState var axisXZoomGestureState: CGFloat = .zero

    @GestureState var axisYDragGestureState: DragGesture.Value?
    @State var axisYMomentum: CGFloat = .zero
    @GestureState var axisYZoomGestureState: CGFloat = .zero

    //
    public init(axisX: PreciseAxis2DViewModel, axisY: PreciseAxis2DViewModel,
                content: @escaping (_ size: CGSize, _ scale: CGSize) -> Content,
                axisXLabel: @escaping (_ value: Double, _ step: Double) -> AxisXLabel,
                axisYLabel: @escaping (_ value: Double, _ step: Double) -> AxisYLabel) {
        self.axisX = axisX
        self.axisY = axisY
        self.content = content
        self.axisXLabel = axisXLabel
        self.axisYLabel = axisYLabel
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vizualizace hodnot
                PreciseContent2DView(
                    scale: CGSize(width: axisX.scale, height: axisY.scale),
                    offset: AnimatablePair(
                        xOffsetTranslation(fromFrameSize: geometry.size),
                        -yOffsetTranslation(fromFrameSize: geometry.size)
                    ),
                    isXInfinite: axisX.isInfinite,
                    isYInfinite: axisY.isInfinite,
                    content: content
                )
                .frame(
                    width: contentSize(fromFrameSize: geometry.size).width,
                    height: contentSize(fromFrameSize: geometry.size).height
                )
                .offset(
                    x: contentOffset(fromFrameSize: geometry.size).width,
                    y: contentOffset(fromFrameSize: geometry.size).height
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($contentDragGestureState) { gesture, state, _ in
                            state = gesture
                        }
                )
                .gesture(
                    MagnificationGesture(minimumScaleDelta: 0)
                        .updating($contentZoomGestureState) { gesture, state, _ in
                            state = gesture
                        }
                )
                .onChange(of: contentDragGestureState) { gesture in
                    if let gesture = gesture {
                        drag(gesture: gesture, onAxis: axisX, withAxisActivation: false, withFrameSize: geometry.size)
                        drag(gesture: gesture, onAxis: axisY, withAxisActivation: false, withFrameSize: geometry.size)
                    }
                    else {
                        finishedDragging(onAxis: axisX, withFrameSize: geometry.size)
                        finishedDragging(onAxis: axisY, withFrameSize: geometry.size)
                    }
                }

                // Osa Y
                ZStack {
                    PreciseAxis2DView(
                        maxValue: axisY.maxValue,
                        minValue: axisY.minValue,
                        value: axisY.unsafeValue,
                        truncScale: axisY.truncScale,
                        isInfinite: axisY.isInfinite,
                        isActive: axisY.active,
                        minDesignValue: minValue(fromFrameSize: geometry.size, forAxis: axisY),
                        maxDesignValue: maxValue(fromFrameSize: geometry.size, forAxis: axisY),
                        numberOfUnits: axisY.numberOfUnits,
                        scaleBase: axisY.scaleBase,
                        valueLabel: { value, step in
                            axisYLabel(value, step)
                                .rotationEffect(.degrees(180))
                        }
                    )
                    .frame(
                        width: contentSize(fromFrameSize: geometry.size).height,
                        height: axisHeight(fromFrameSize: geometry.size) * 2
                    )
                    .rotationEffect(.degrees(90))
                }
                .frame(
                    width: (geometry.size.width - contentSize(fromFrameSize: geometry.size).width) * 2,
                    height: contentSize(fromFrameSize: geometry.size).height
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($axisYDragGestureState) { gesture, state, _ in
                            state = gesture
                        }
                )
                .gesture(
                    MagnificationGesture(minimumScaleDelta: 0)
                        .updating($axisYZoomGestureState) { gesture, state, _ in
                            state = gesture
                        }
                )
                .onChange(of: axisYDragGestureState) { gesture in
                    if let gesture = gesture {
                        drag(gesture: gesture, onAxis: axisY, withAxisActivation: true, withFrameSize: geometry.size)
                    }
                    else {
                        finishedDragging(onAxis: axisY, withFrameSize: geometry.size)
                    }
                }
                .offset(
                    x: (contentSize(fromFrameSize: geometry.size).width - axisHeight(fromFrameSize: geometry.size)) / 2,
                    y: (contentSize(fromFrameSize: geometry.size).height - geometry.size.height) / 2
                )

                // Osa X
                ZStack {
                    PreciseAxis2DView(
                        maxValue: axisX.minValue,
                        minValue: axisX.maxValue,
                        value: axisX.unsafeValue,
                        truncScale: axisX.truncScale,
                        isInfinite: axisX.isInfinite,
                        isActive: axisX.active,
                        minDesignValue: minValue(fromFrameSize: geometry.size, forAxis: axisX),
                        maxDesignValue: maxValue(fromFrameSize: geometry.size, forAxis: axisX),
                        numberOfUnits: axisX.numberOfUnits,
                        scaleBase: axisX.scaleBase,
                        valueLabel: { value, step in
                            axisXLabel(value, step)
                                .rotationEffect(.degrees(180))
                        }
                    )
                    .rotationEffect(.degrees(180))
                    .frame(
                        width: contentSize(fromFrameSize: geometry.size).width,
                        height: axisHeight(fromFrameSize: geometry.size) * 2
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($axisXDragGestureState) { gesture, state, _ in
                                state = gesture
                            }
                    )
                    .gesture(
                        MagnificationGesture(minimumScaleDelta: 0)
                            .updating($axisXZoomGestureState) { gesture, state, _ in
                                state = gesture
                            }
                    )
                    .onChange(of: axisXDragGestureState) { gesture in
                        if let gesture = gesture {
                            drag(
                                gesture: gesture,
                                onAxis: axisX,
                                withAxisActivation: true,
                                withFrameSize: geometry.size
                            )
                        }
                        else {
                            finishedDragging(onAxis: axisX, withFrameSize: geometry.size)
                        }
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .bottomLeading
                )

                // Okraj komponenty (roh mezi osami)
                Rectangle()
                    .frame(
                        width: cornerSize(fromFrameSize: geometry.size).width,
                        height: cornerSize(fromFrameSize: geometry.size).height
                    )
                    .offset(cornerOffset(fromFrameSize: geometry.size))
                    .foregroundColor(style.axisBackgroundColor)
            }
            .clipShape(Rectangle())
            .onChange(of: axisXZoomGestureState) { value in
                zoom(byValue: value, withAxisActivation: true, onAxis: axisX)
            }
            .onChange(of: axisYZoomGestureState) { value in
                zoom(byValue: value, withAxisActivation: true, onAxis: axisY)
            }
            .onChange(of: contentZoomGestureState) { value in
                zoom(byValue: value, withAxisActivation: false, onAxis: axisX)
                zoom(byValue: value, withAxisActivation: false, onAxis: axisY)
            }
        }
    }

    private func zoom(byValue value: CGFloat, withAxisActivation active: Bool, onAxis axis: PreciseAxis2DViewModel) {
        if value != 0 {
            if active {
                axis.activeZoom(byValue: value)
            }
            else {
                axis.zoom(byValue: value)
            }
        }
        else {
            axis.editingScaleEnded()
        }
    }

    private func drag(gesture: DragGesture.Value,
                      onAxis axis: PreciseAxis2DViewModel,
                      withAxisActivation active: Bool,
                      withFrameSize frame: CGSize) {
        if gesture.translation.width != 0 && gesture.translation.height != 0 {
            var value = axis === axisX ?
                gesture.translation.width : gesture.translation.height
            value = value * gestureCoefitient(fromFrameSize: frame, forAxis: axis)

            if active {
                axis.activeMove(byValue: value)
            }
            else {
                axis.move(byValue: value)
            }
        }

        axisXMomentum = (gesture.predictedEndTranslation.width - gesture.translation.width)
        axisYMomentum = (gesture.predictedEndTranslation.height - gesture.translation.height)
    }

    private func finishedDragging(onAxis axis: PreciseAxis2DViewModel, withFrameSize frame: CGSize) {
        axis.animateMomentum(
            byValue: axis === axisX ? axisXMomentum : axisYMomentum,
            translationCoefitient: gestureCoefitient(
                fromFrameSize: frame,
                forAxis: axis
            ),
            duration: 1
        )

        axis.editingValueEnded()
    }

    //
    // Převod aktuálně zvolené hodnoty na posun vizualizace
    private func xOffsetTranslation(fromFrameSize frame: CGSize) -> CGFloat {
        let valueRange = (axisX.maxValue - axisX.minValue)

        if valueRange != 0 {
            return (axisX.maxValue - axisX.unsafeValue)
                * (maxValue(fromFrameSize: frame, forAxis: axisX) - minValue(fromFrameSize: frame, forAxis: axisX))
                / valueRange
                + minValue(fromFrameSize: frame, forAxis: axisX)
        }
        else {
            return 0
        }
    }

    private func yOffsetTranslation(fromFrameSize frame: CGSize) -> CGFloat {
        let valueRange = (axisY.maxValue - axisY.minValue)

        if valueRange != 0 {
            return (axisY.unsafeValue - axisY.minValue)
                * (maxValue(fromFrameSize: frame, forAxis: axisY) - minValue(fromFrameSize: frame, forAxis: axisY))
                / valueRange
                + minValue(fromFrameSize: frame, forAxis: axisY)
        }
        else {
            return 0
        }
    }

    //
    private func axisOffset(fromWidth width: CGFloat, isActive active: Bool) -> CGFloat {
        if active {
            return width * CGFloat(9/10)
        }
        else {
            return width * CGFloat(19/20)
        }
    }

    private func cornerOffset(fromFrameSize frame: CGSize) -> CGSize {
        let x = frame.width / 2
        let y = frame.height / 2
        let axisSize = axisHeight(fromFrameSize: frame)

        return .init(
            width: x - (axisSize / (axisY.active ? 1 : 2)),
            height: y - (axisSize / (axisX.active ? 1 : 2))
        )
    }

    private func cornerSize(fromFrameSize frame: CGSize) -> CGSize {
        return .init(
            width: axisHeight(fromFrameSize: frame) * (axisY.active ? 2 : 1),
            height: axisHeight(fromFrameSize: frame) * (axisX.active ? 2 : 1)
        )
    }

    private func contentSize(fromFrameSize frame: CGSize) -> CGSize {
        return .init(
            width: frame.width - axisHeight(fromFrameSize: frame),
            height: frame.height - axisHeight(fromFrameSize: frame)
        )
    }

    private func contentOffset(fromFrameSize frame: CGSize) -> CGSize {
        return .init(
            width: -(axisHeight(fromFrameSize: frame) / 2),
            height: -(axisHeight(fromFrameSize: frame) / 2)
        )
    }

    private func axisHeight(fromFrameSize frame: CGSize) -> CGFloat {
        min(frame.width, frame.height) * 0.05
    }

    private func maxValue(fromFrameSize frame: CGSize, forAxis viewModel: PreciseAxis2DViewModel) -> CGFloat {
        let size = contentSize(fromFrameSize: frame)

        return viewModel === axisX ? (size.width / 2) : (size.height / 2)
    }

    private func minValue(fromFrameSize frame: CGSize, forAxis viewModel: PreciseAxis2DViewModel) -> CGFloat {
        -maxValue(fromFrameSize: frame, forAxis: viewModel)
    }

    // Převod délky gesta na hodnotu ekfivalentní rozsahu osy
    private func gestureCoefitient(fromFrameSize frame: CGSize, forAxis axis: PreciseAxis2DViewModel) -> CGFloat {
        let axisRange = maxValue(fromFrameSize: frame, forAxis: axis) - minValue(fromFrameSize: frame, forAxis: axis)

        if axisRange > 0 {
            return (axis.maxValue - axis.minValue) / axisRange
        }
        else {
            return 0
        }
    }
}

struct PreciseSlider2DView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PreciseSlider2DView(
                axisX: PreciseAxis2DViewModel(
                    minValue: 100,
                    maxValue: 0,
                    isInfinite: false
                ),
                axisY: PreciseAxis2DViewModel(
                    minValue: 100,
                    maxValue: 0,
                    isInfinite: true
                ),
                content: { size, _ in
                    ZStack {
                        Rectangle()
                            .foregroundColor(.brown)
                        Rectangle()
                            .foregroundColor(.blue)
                            .frame(height: size.height / 3)
                        Rectangle()
                            .foregroundColor(.red)
                            .frame(width: 1, height: 20)
                        Rectangle()
                            .foregroundColor(.red)
                            .frame(width: 20, height: 1)
                    }
                    .border(.red)
                },
                axisXLabel: { value, _ in
                    Text("\(value)")
                        .font(.system(size: 6))
                },
                axisYLabel: { value, _ in
                    Text("\(value)")
                        .font(.system(size: 6))
                }
            )
            .frame(width: 300, height: 300, alignment: .center)
        }
    }
}
