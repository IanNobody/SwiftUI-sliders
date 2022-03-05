//
//  PreciseAxisView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 16.02.2022.
//

import SwiftUI

struct PreciseAxis2DView: View {
    @ObservedObject var viewModel: PreciseAxis2DViewModel
    
    init(viewModel: PreciseAxis2DViewModel) {
        self.viewModel = viewModel
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
                            // TODO: Dynamická velikost jednotky
                            height: unitHeight(forIndex: index, withFrameWidth: geometry.size.width)
                        )
                        .foregroundColor(.white)
                        .offset(
                            x: normalizedOffset(
                                fromOffset: viewModel.unitOffset(forIndex: index),
                                withWidth: geometry.size.width
                            ),
                            y: viewModel.active ?
                                // TODO: Má tato konstanta opodstatnění?
                                2.5 :
                                .zero
                        )
                }
                .frame(
                    width: geometry.size.width,
                    height: axisHeight(fromFrameWidth: geometry.size.width),
                    alignment: viewModel.active ?
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
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        viewModel.interruptAnimation()
                        
                        viewModel.move(byValue: gesture.translation.width)
                        
                        // Roztažení osy
                        withAnimation(.easeInOut) {
                            viewModel.active = true
                        }
                    }
                    .onEnded { gesture in
                        viewModel.editingValueEnded()
                        
                        viewModel.animateMomentum(byValue: (gesture.translation.width - gesture.predictedEndTranslation.width) / viewModel.scale)
                        
                        // Návrat do původní podoby po 2s od roztažení
                        withAnimation(.easeInOut.delay(2)) {
                            viewModel.active = false
                        }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { gesture in
                        viewModel.interruptAnimation()
                        
                        let newScale = viewModel.prevScale * gesture.magnitude
                        
                        viewModel.scale = newScale > 1.0 ? newScale : 1.0
                    }
            )
        }
    }
    
    // TODO: Stejný kód je i v 1D slideru, musí se opakovat?
    private func maximumUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfUnits(fromWidth: width)) * viewModel.designUnit
    }
    
    private func normalizedOffset(fromOffset offset: CGFloat, withWidth width: CGFloat) -> CGFloat {
        let max = maximumUnitOffset(fromWidth: width)
        
        let scaleCorrection = viewModel.designUnit * CGFloat(middleIndex(fromWidth: width))
        
        if offset > max {
            return (offset.truncatingRemainder(dividingBy: max) - scaleCorrection)
        }
        
        if offset < 0 {
            return max + (offset.truncatingRemainder(dividingBy: max) - scaleCorrection)
        }
        
        return (offset - scaleCorrection)
    }
    
    private func numberOfUnits(fromWidth width: CGFloat) -> Int {
        let num = Int(ceil(width / CGFloat(viewModel.defaultStep)))
        
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
    
    private func axisHeight(fromFrameWidth frame: CGFloat) -> CGFloat {
        if viewModel.active {
            return frame / 10
        }
        else {
            return frame / 20
        }
    }
    
    // Index jednotky s ohledem na zvolenou hodnotu
    public func relativeIndex(forIndex index: Int, withWidth width: CGFloat) -> Int {
        
        let indexOffset = index - Int(viewModel.value / viewModel.unit)
        
        // Zaokrouhlení k nejbližšímu nižšímu násobku celkového počtu jednotek
        let roundedOffset = Int(floor(
            Float(indexOffset)
            / Float(numberOfUnits(fromWidth: width))
        )) * numberOfUnits(fromWidth: width)

        return index - roundedOffset
    }
    
    func unitHeight(forIndex index: Int, withFrameWidth width: CGFloat) -> CGFloat {
        let height = axisHeight(fromFrameWidth: width)
            * viewModel.unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: width))
            * 0.8
        
        return viewModel.active ? height/2 : height
    }
}

struct PreciseAxis2DView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseAxis2DView(viewModel: PreciseAxis2DViewModel())
    }
}
