//
//  PreciseSlider2D.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 15.02.2022.
//

import SwiftUI

struct PreciseSlider2D<Content:View>: View {
    @ObservedObject var axisX: PreciseAxis2DViewModel
    @ObservedObject var axisY: PreciseAxis2DViewModel
    
    @ViewBuilder let content: (_ scale: CGFloat) -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    content(axisX.scale)
                        .frame(
                            width:
                                contentSize(fromFrameSize: geometry.size).width,
                            height:
                                contentSize(fromFrameSize: geometry.size).height
                        )
                        .offset(
                            x: xOffsetTranslation(fromFrameSize: geometry.size),
                            y: -yOffsetTranslation(fromFrameSize: geometry.size)
                        )
                        .scaleEffect(.init(width: axisX.scale, height: axisY.scale))
                    
                    Rectangle()
                        .frame(width: 1, height: 20)
                        .overlay(
                            content(axisX.scale)
                                .frame(
                                    width:
                                        contentSize(fromFrameSize: geometry.size).width,
                                    height:
                                        contentSize(fromFrameSize: geometry.size).height
                                )
                                .offset(
                                    x: xOffsetTranslation(fromFrameSize: geometry.size),
                                    y: -yOffsetTranslation(fromFrameSize: geometry.size)
                                )
                                .scaleEffect(.init(width: axisX.scale, height: axisY.scale))
                        )
                        .clipShape(Rectangle())
                        .colorInvert()
                    Rectangle()
                        .frame(width: 20, height: 1)
                        .overlay(
                            content(axisX.scale)
                                .frame(
                                    width:
                                        contentSize(fromFrameSize: geometry.size).width,
                                    height:
                                        contentSize(fromFrameSize: geometry.size).height
                                )
                                .offset(
                                    x: xOffsetTranslation(fromFrameSize: geometry.size),
                                    y: -yOffsetTranslation(fromFrameSize: geometry.size)
                                )
                                .scaleEffect(.init(width: axisX.scale, height: axisY.scale))
                        )
                        .clipShape(Rectangle())
                        .colorInvert()
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                .background(.gray)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            axisX.move(byValue: -gesture.translation.width * gestureXCoefitient(fromFrameSize: geometry.size))
                            axisY.move(byValue: gesture.translation.height * gestureYCoefitient(fromFrameSize: geometry.size))
                        }
                        .onEnded { gesture in
                            axisX.animateMomentum(byValue: (gesture.translation.width - gesture.predictedEndTranslation.width) * gestureXCoefitient(fromFrameSize: geometry.size), duration: 1)
                            
                            axisY.animateMomentum(byValue: (gesture.predictedEndTranslation.height - gesture.translation.height) * gestureYCoefitient(fromFrameSize: geometry.size), duration: 1)
                            
                            axisX.editingValueEnded()
                            axisY.editingValueEnded()
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { gesture in
                            axisX.zoom(byScale: gesture.magnitude)
                            axisY.zoom(byScale: gesture.magnitude)
                        }
                        .onEnded { _ in
                            axisX.editingScaleEnded()
                            axisY.editingScaleEnded()
                        }
                )
                
                // Osa Y
                ZStack {
                    PreciseAxis2DView(maxValue: axisY.maxValue, minValue: axisY.minValue, value: axisY.value, truncScale: axisY.truncScale, isInfinite: axisY.isInfinite, isActive: axisY.active, minDesignValue: minYValue(fromFrameSize: geometry.size), maxDesignValue: maxYValue(fromFrameSize: geometry.size), defaultStep: axisY.unitSize, scaleBase: axisY.scaleBase, valueLabel: { value in
                            Text("\(Int(value))")
                                .rotationEffect(.degrees(-90))
                                .foregroundColor(.white)
                                .font(
                                    .system(size: 7, design: .rounded)
                                )
                        }
                    )
                    .rotationEffect(.degrees(90))
                    .frame(width: contentSize(fromFrameSize: geometry.size).height, height: geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                axisY.activeMove(byValue: gesture.translation.height * gestureYCoefitient(fromFrameSize: geometry.size))
                            }
                            .onEnded { gesture in
                                axisY.animateMomentum(byValue: (gesture.predictedEndTranslation.height - gesture.translation.height) * gestureYCoefitient(fromFrameSize: geometry.size), duration: 0.5)

                                axisY.editingValueEnded()
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { gesture in
                                axisY.zoom(byScale: gesture.magnitude)
                            }
                            .onEnded { _ in
                                axisY.editingScaleEnded()
                            }
                    )
                    .offset(y: -contentOffset(fromFrameSize: geometry.size).height)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                
                // Osa X
                ZStack {
                    PreciseAxis2DView(maxValue: axisX.maxValue, minValue: axisX.minValue, value: axisX.value, truncScale: axisX.truncScale, isInfinite: axisX.isInfinite, isActive: axisX.active, minDesignValue: minXValue(fromFrameSize: geometry.size), maxDesignValue: maxXValue(fromFrameSize: geometry.size), defaultStep: axisX.unitSize, scaleBase: axisX.scaleBase, valueLabel: { value in
                            Text("\(Int(value))")
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.white)
                                .font(
                                    .system(size: 7, design: .rounded)
                                )
                        }
                    )
                        .rotationEffect(.degrees(-180))
                        .frame(width: contentSize(fromFrameSize: geometry.size).width, height: contentSize(fromFrameSize: geometry.size).height)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    axisX.activeMove(byValue: -gesture.translation.width * gestureXCoefitient(fromFrameSize: geometry.size))
                                }
                                .onEnded { gesture in
                                    axisX.animateMomentum(byValue: (gesture.translation.width - gesture.predictedEndTranslation.width) * gestureXCoefitient(fromFrameSize: geometry.size), duration: 0.5)

                                    axisX.editingValueEnded()
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { gesture in
                                    axisX.zoom(byScale: gesture.magnitude)
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
                
                Rectangle()
                    .frame(width:
                            cornerSize(
                                fromWidth: geometry.size.width,
                                fromHeight: geometry.size.height
                            ).width,
                           height:
                            cornerSize(
                                fromWidth: geometry.size.width,
                                fromHeight: geometry.size.height
                            ).height
                    )
                    .offset(
                        cornerOffset(
                            fromWidth: geometry.size.width,
                            fromHeight: geometry.size.height
                        )
                    )
                    .foregroundColor(.black)
            }
            .clipShape(Rectangle())
        }
    }
    
    // TODO: Ošetřit dělení nulou
    private func xOffsetTranslation(fromFrameSize frame: CGSize) -> CGFloat {
        (axisX.value - axisX.minValue) * (maxXValue(fromFrameSize: frame) - minXValue(fromFrameSize: frame)) / (axisX.maxValue - axisX.minValue) + minXValue(fromFrameSize: frame)
    }
    
    private func yOffsetTranslation(fromFrameSize frame: CGSize) -> CGFloat {
        (axisY.value - axisY.minValue) * (maxYValue(fromFrameSize: frame) - minYValue(fromFrameSize: frame)) / (axisY.maxValue - axisY.minValue) + minYValue(fromFrameSize: frame)
    }
    
    private func axisOffset(fromWidth width: CGFloat, isActive active: Bool) -> CGFloat {
        if active {
            return width * CGFloat(9/10)
        }
        else {
            return width * CGFloat(19/20)
        }
    }
    
    private func cornerOffset(fromWidth width: CGFloat, fromHeight height: CGFloat) -> CGSize {
        let x = width / 2
        let y = height / 2
        
        return .init(
            width: x - (width / (axisY.active ? 20.0 : 40.0)),
            height: y - (height / (axisX.active ? 20.0 : 40.0))
        )
    }
    
    private func cornerSize(fromWidth width: CGFloat, fromHeight height: CGFloat) -> CGSize {
        return .init(
            width: width / (axisY.active ? 10.0 : 20.0),
            height: height / (axisX.active ? 10.0 : 20.0)
        )
    }
    
    private func contentSize(fromFrameSize frame: CGSize) -> CGSize {
        return .init(
            width: frame.width * 0.95,
            height: frame.height * 0.95
        )
    }
    
    private func contentOffset(fromFrameSize frame: CGSize) -> CGSize {
        return .init(
            width: frame.width * 0.025,
            height: frame.height * 0.025
        )
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
    
    private func gestureXCoefitient(fromFrameSize frame: CGSize) -> CGFloat {
        (axisX.maxValue - axisX.minValue) / (maxXValue(fromFrameSize: frame) - minXValue(fromFrameSize: frame))
    }
    
    private func gestureYCoefitient(fromFrameSize frame: CGSize) -> CGFloat {
        (axisY.maxValue - axisY.minValue) / (maxYValue(fromFrameSize: frame) - minYValue(fromFrameSize: frame))
    }
}

struct PreciseSlider2D_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSlider2D(
            axisX: PreciseAxis2DViewModel(),
            axisY: PreciseAxis2DViewModel(),
            content: { scale in
                ZStack {
                    Rectangle()
                        .foregroundColor(.brown)
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: 1, height: 20)
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: 20, height: 1)
                }
            }
        )
        .frame(width: 300, height: 300, alignment: .center)
    }
}
