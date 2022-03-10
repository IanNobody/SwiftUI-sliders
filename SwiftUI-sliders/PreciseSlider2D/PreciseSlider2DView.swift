//
//  PreciseSlider2D.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 15.02.2022.
//

import SwiftUI

struct PreciseSlider2D: View {
    @ObservedObject var viewModel = PreciseSlider2DViewModel()
    
    @ObservedObject var axisX = PreciseAxis2DViewModel()
    @ObservedObject var axisY = PreciseAxis2DViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                    Rectangle()
                        .offset(
                            x: axisX.value,
                            y: -axisY.value
                        )
                        .foregroundColor(.brown)
                        .scaleEffect(.init(width: axisX.scale, height: axisY.scale))
                        .clipShape(Rectangle())
                    Rectangle()
                        .frame(width: 1, height: 20)
                        .foregroundColor(.blue)
                    Rectangle()
                        .frame(width: 20, height: 1)
                        .foregroundColor(.blue)
                }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            axisX.move(byValue: -gesture.translation.width)
                            axisY.move(byValue: gesture.translation.height)
                        }
                        .onEnded { gesture in
                            axisX.animateMomentum(byValue: gesture.translation.width - gesture.predictedEndTranslation.width, duration: 1)
                            
                            axisY.animateMomentum(byValue: gesture.predictedEndTranslation.height - gesture.translation.height, duration: 1)
                            
                            axisX.editingValueEnded()
                            axisY.editingValueEnded()
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { gesture in
                            let newScaleX = axisX.prevScale * gesture.magnitude
                            
                            let newScaleY = axisY.prevScale * gesture.magnitude
                            
                            axisX.scale = newScaleX > 0.5 ? newScaleX : 0.5
                            axisY.scale = newScaleY > 0.5 ? newScaleY : 0.5
                        }
                        .onEnded { _ in
                            axisX.editingScaleEnded()
                            axisY.editingScaleEnded()
                        }
                )
                
                
                // Osa Y
                PreciseAxis2DView(maxValue: axisY.maxValue, minValue: axisY.minValue, value: axisY.value, truncScale: axisY.truncScale, designUnit: axisY.designUnit, unit: axisY.unit, isInfinite: axisY.isInfinite, isActive: axisY.active)
                    .rotationEffect(.degrees(90))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                axisY.activeMove(byValue: gesture.translation.height)
                            }
                            .onEnded { gesture in
                                axisY.animateMomentum(byValue: (gesture.predictedEndTranslation.height - gesture.translation.height), duration: 0.5)

                                axisY.editingValueEnded()
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { gesture in
                                let newScale = axisY.prevScale * gesture.magnitude
                                
                                axisY.scale = newScale > 1.0 ? newScale : 1.0
                            }
                    )
                
                // Osa X
                PreciseAxis2DView(maxValue: axisX.maxValue, minValue: axisX.minValue, value: axisX.value, truncScale: axisX.truncScale, designUnit: axisX.designUnit, unit: axisX.unit, isInfinite: axisX.isInfinite, isActive: axisX.active)
                    .rotationEffect(.degrees(-180))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                axisX.activeMove(byValue: -gesture.translation.width)
                            }
                            .onEnded { gesture in
                                axisX.animateMomentum(byValue: (gesture.predictedEndTranslation.width - gesture.translation.width), duration: 0.5)

                                axisX.editingValueEnded()
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { gesture in
                                let newScale = axisX.prevScale * gesture.magnitude
                                
                                axisX.scale = newScale > 1.0 ? newScale : 1.0
                            }
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
        }
        .frame(width: 310, height: 310, alignment: .topLeading)
    }
    
    private func interationStarted() {
        withAnimation(.easeInOut) {
            axisX.active = true
            axisY.active = true
        }
    }
    
    private func interactionEnded() {
        withAnimation(.easeInOut.delay(2)) {
            axisX.active = false
            axisY.active = false
        }
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
            width: x - (height / (axisY.active ? 20.0 : 40.0)),
            height: y - (width / (axisX.active ? 20.0 : 40.0))
        )
    }
    
    private func cornerSize(fromWidth width: CGFloat, fromHeight height: CGFloat) -> CGSize {
        return .init(
            width: height / (axisY.active ? 10.0 : 20.0),
            height: width / (axisX.active ? 10.0 : 20.0)
        )
    }
}

struct PreciseSlider2D_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSlider2D()
    }
}
