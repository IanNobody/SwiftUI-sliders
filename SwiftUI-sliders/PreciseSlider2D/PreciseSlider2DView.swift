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
                            axisX.interruptAnimation()
                            axisY.interruptAnimation()
                            
                            axisX.value = axisX.prevValue + (gesture.translation.width / axisX.scale)
                            axisY.value = axisY.prevValue - (gesture.translation.height / axisY.scale)
                        }
                        .onEnded { gesture in
                            axisX.editingValueEnded()
                            axisY.editingValueEnded()
                            
                            axisX.animateMomentum(byValue: (gesture.predictedEndTranslation.width - gesture.translation.width) / axisX.scale)
                            
                            axisY.animateMomentum(byValue: (gesture.translation.height - gesture.predictedEndTranslation.height) / axisY.scale)
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
                PreciseAxis2DView(viewModel: axisY)
                    .rotationEffect(.degrees(90))
                
                // Osa X
                PreciseAxis2DView(viewModel: axisX)
                    .rotationEffect(.degrees(180))
                
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
