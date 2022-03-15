//
//  PreciseSlider.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 01.02.2022.
//

import SwiftUI

struct PreciseSliderView: View {
    @ObservedObject var viewModel: PreciseSliderViewModel
    
    // TODO: Rozdělit rozhraní pro UIKit a SwiftUI elegantnějším způsobem
    // TODO: Vyřešit chyby vzniklé nedokončenými gesty (nevyvolání události .onEnded)
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PreciseSliderAxisView(maxValue: viewModel.maxValue, minValue: viewModel.minValue, value: viewModel.value, truncScale: viewModel.truncScale, isInfinite: viewModel.isInfinite, maxDesignValue: maxDesignValue(fromWidth: geometry.size.width), minDesignValue: minDesignValue(fromWidth: geometry.size.width), scaleBase: viewModel.scaleBase, unitSize: viewModel.defaultStep)
            }
            // Výběr hodnoty
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        viewModel.move(byValue: gesture.translation.width / gestureCoefitient(fromWidth: geometry.size.width))
                    }
                    .onEnded { gesture in
                        viewModel.animateMomentum(byValue: (gesture.predictedEndTranslation.width - gesture.translation.width) / gestureCoefitient(fromWidth: geometry.size.width), duration: 0.5)

                        viewModel.editingValueEnded()
                    }
            )
            // Výběr měřítka
            .gesture(
                MagnificationGesture()
                    .onChanged { gesture in
                        viewModel.zoom(byScale: gesture.magnitude)
                    }
                    .onEnded { _ in
                        viewModel.editingScaleEnded()
                    }
            )
            // TODO: Zastavení animace jinými gesty
        }
    }
    
    private func maxDesignValue(fromWidth width: CGFloat) -> CGFloat {
        return width
    }
    
    private func minDesignValue(fromWidth width: CGFloat) -> CGFloat {
        return -width
    }
    
    private func gestureCoefitient(fromWidth width: CGFloat) -> CGFloat {
        (maxDesignValue(fromWidth: width) - minDesignValue(fromWidth: width)) / (viewModel.maxValue - viewModel.minValue)
    }
}

struct PreciseSliderView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderView(viewModel: PreciseSliderViewModel())
            .frame(width: 300, height: 50, alignment: .center)
    }
}
