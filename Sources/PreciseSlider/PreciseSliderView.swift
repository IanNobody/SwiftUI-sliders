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
    
    public init(viewModel: PreciseSliderViewModel, valueLabel: @escaping (_ value: CGFloat, _ stepSize: CGFloat) -> ValueLabel?) {
        self.viewModel = viewModel
        self.valueLabel = valueLabel
    }
    
    // TODO: Opravit podivně se chovající animaci na "hranicích" nekonečného varianty
    // TODO: Vyřešit chyby vzniklé nedokončenými gesty (nevyvolání události .onEnded)
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                PreciseAxisView(maxValue: viewModel.maxValue, minValue: viewModel.minValue, value: viewModel.value, truncScale: viewModel.truncScale, isInfinite: viewModel.isInfinite, maxDesignValue: maxDesignValue(fromWidth: geometry.size.width), minDesignValue: minDesignValue(fromWidth: geometry.size.width), scaleBase: viewModel.scaleBase, numberOfUnits: viewModel.numberOfUnits, valueLabel: valueLabel)
            }
            // Výběr hodnoty
            // TODO: Ošetřit minimální délky gest a animací
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        viewModel.move(byValue: gesture.translation.width * gestureCoefitient(fromWidth: geometry.size.width))
                    }
                    .onEnded { gesture in
                        viewModel.animateMomentum(byValue: (gesture.predictedEndTranslation.width - gesture.translation.width) * gestureCoefitient(fromWidth: geometry.size.width), duration: 0.5)

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
        PreciseSliderView(viewModel: PreciseSliderViewModel(isInfinite: true), valueLabel: { value, step in
            Text("\(value)")
                .background(.black)
                .font(.system(size: 7, design: .rounded))
                .foregroundColor(.white)
        })
        .frame(width: 350, height: 50, alignment: .center)
    }
}
