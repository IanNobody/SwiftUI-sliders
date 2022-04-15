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

    public init(axisX: PreciseAxis2DViewModel,
                axisY: PreciseAxis2DViewModel,
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
                        .onChanged { gesture in
                            axisX.move(
                                byValue: gesture.translation.width
                                    * gestureXCoefitient(fromFrameSize: geometry.size)
                            )
                            axisY.move(
                                byValue: gesture.translation.height
                                    * gestureYCoefitient(fromFrameSize: geometry.size)
                            )
                        }
                        .onEnded { gesture in
                            finishedDragging(
                                gesture: gesture,
                                onAxis: axisX,
                                withFrameSize: geometry.size
                            )
                            finishedDragging(
                                gesture: gesture,
                                onAxis: axisY,
                                withFrameSize: geometry.size
                            )
                        }
                )
                .gesture(
                    MagnificationGesture(minimumScaleDelta: 0)
                        .onChanged { gesture in
                            axisX.zoom(byValue: gesture.magnitude)
                            axisY.zoom(byValue: gesture.magnitude)
                        }
                        .onEnded { _ in
                            axisX.editingScaleEnded()
                            axisY.editingScaleEnded()
                        }
                )

                // Osa Y
                ZStack {
                    PreciseAxis2DView(
                        maxValue: axisY.maxValue,
                        minValue: axisY.minValue,
                        value: axisY.unsafeValue,
                        truncScale: axisY.truncScale,
                        isInfinite: axisY.isInfinite,
                        isActive: axisY.active,
                        minDesignValue: minYValue(
                            fromFrameSize: geometry.size
                        ),
                        maxDesignValue: maxYValue(
                            fromFrameSize: geometry.size
                        ),
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
                        .onChanged { gesture in
                            axisY.activeMove(
                                byValue: gesture.translation.height
                                    * gestureYCoefitient(fromFrameSize: geometry.size)
                            )
                        }
                        .onEnded { gesture in
                            finishedDragging(
                                gesture: gesture,
                                onAxis: axisY,
                                withFrameSize: geometry.size
                            )
                        }
                )
                .gesture(
                    MagnificationGesture(minimumScaleDelta: 0)
                        .onChanged { gesture in
                            axisY.zoom(byValue: gesture.magnitude)
                        }
                        .onEnded { _ in
                            axisY.editingScaleEnded()
                        }
                )
                .offset(
                    x: (
                        contentSize(fromFrameSize: geometry.size).width
                        - axisHeight(fromFrameSize: geometry.size)
                    ) / 2,
                    y: (
                        contentSize(fromFrameSize: geometry.size).height
                        - geometry.size.height
                    ) / 2
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
                        minDesignValue: minXValue(
                            fromFrameSize: geometry.size
                        ),
                        maxDesignValue: maxXValue(
                            fromFrameSize: geometry.size
                        ),
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
                        DragGesture()
                            .onChanged { gesture in
                                axisX.activeMove(
                                    byValue: gesture.translation.width
                                        * gestureXCoefitient(fromFrameSize: geometry.size)
                                )
                            }
                        .onEnded { gesture in
                                finishedDragging(
                                    gesture: gesture,
                                    onAxis: axisX,
                                    withFrameSize: geometry.size
                                )
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { gesture in
                                axisX.zoom(byValue: gesture.magnitude)
                            }
                            .onEnded { _ in
                                axisX.editingScaleEnded()
                            }
                    )
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .bottomLeading
                )

                // Okraj komponenty (roh mezi osami)
                Rectangle()
                    .frame(
                        width:
                            cornerSize(fromFrameSize: geometry.size).width,
                        height:
                            cornerSize(fromFrameSize: geometry.size).height
                    )
                    .offset(cornerOffset(fromFrameSize: geometry.size))
                    .foregroundColor(style.axisBackgroundColor)
            }
            .clipShape(Rectangle())
        }
    }

    private func finishedDragging(gesture: DragGesture.Value,
                                  onAxis viewModel: PreciseAxis2DViewModel,
                                  withFrameSize frame: CGSize) {
        let value = viewModel === axisX ?
            (gesture.predictedEndTranslation.width - gesture.translation.width)
            : (gesture.predictedEndTranslation.height - gesture.translation.height)

        viewModel.animateMomentum(
            byValue: value,
            translationCoefitient: gestureXCoefitient(fromFrameSize: frame),
            duration: 1
        )

        viewModel.editingValueEnded()
    }

    //
    // Převod aktuálně zvolené hodnoty na posun vizualizace
    private func xOffsetTranslation(fromFrameSize frame: CGSize) -> CGFloat {
        let valueRange = (axisX.maxValue - axisX.minValue)

        if valueRange != 0 {
            return (axisX.maxValue - axisX.unsafeValue)
                * (maxXValue(fromFrameSize: frame) - minXValue(fromFrameSize: frame))
                / valueRange
                + minXValue(fromFrameSize: frame)
        }
        else {
            return 0
        }
    }

    private func yOffsetTranslation(fromFrameSize frame: CGSize) -> CGFloat {
        let valueRange = (axisY.maxValue - axisY.minValue)

        if valueRange != 0 {
            return (axisY.unsafeValue - axisY.minValue)
                * (maxYValue(fromFrameSize: frame) - minYValue(fromFrameSize: frame))
                / valueRange
                + minYValue(fromFrameSize: frame)
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

    private func maxXValue(fromFrameSize frame: CGSize) -> CGFloat {
        return (contentSize(fromFrameSize: frame).width / 2)
    }

    private func minXValue(fromFrameSize frame: CGSize) -> CGFloat {
        return -(contentSize(fromFrameSize: frame).width / 2)
    }

    private func maxYValue(fromFrameSize frame: CGSize) -> CGFloat {
        return (contentSize(fromFrameSize: frame).height / 2)
    }

    private func minYValue(fromFrameSize frame: CGSize) -> CGFloat {
        return -(contentSize(fromFrameSize: frame).height / 2)
    }

    // Převod délky gesta na hodnotu ekfivalentní rozsahu osy X
    private func gestureXCoefitient(fromFrameSize frame: CGSize) -> CGFloat {
        let axisRange = (maxXValue(fromFrameSize: frame) - minXValue(fromFrameSize: frame))

        if axisRange > 0 {
            return (axisX.maxValue - axisX.minValue) / axisRange
        }
        else {
            return 0
        }
    }

    // Převod délky gesta na hodnotu ekfivalentní rozsahu osy Y
    private func gestureYCoefitient(fromFrameSize frame: CGSize) -> CGFloat {
        let axisRange = (maxYValue(fromFrameSize: frame) - minYValue(fromFrameSize: frame))

        if axisRange > 0 {
            return (axisY.maxValue - axisY.minValue) / axisRange
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
