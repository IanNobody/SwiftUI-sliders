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
        ZStack {
            PreciseSliderAxisView(maxValue: viewModel.maxValue, minValue: viewModel.minValue, value: viewModel.value, truncScale: viewModel.truncScale, designUnit: viewModel.designUnit, unit: viewModel.unit, isInfinite: viewModel.isInfinite)
        }
        // Výběr hodnoty
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    viewModel.move(byValue: gesture.translation.width)
                }
                .onEnded { gesture in
                    viewModel.animateMomentum(byValue: (gesture.predictedEndTranslation.width - gesture.translation.width), duration: 0.5)

                    viewModel.editingValueEnded()
                }
        )
        // Výběr měřítka
        .gesture(
            MagnificationGesture()
                .onChanged { gesture in
                    let newScale = viewModel.prevScale * gesture.magnitude
                    
                    // Ošetření minimální hodnoty
                    viewModel.scale = newScale > 1 ? newScale : 1.0
                }
                .onEnded { _ in
                    viewModel.editingScaleEnded()
                }
        )
        // TODO: Zastavení animace jinými gesty
    }
}

struct PreciseSliderView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderView(viewModel: PreciseSliderViewModel())
    }
}
