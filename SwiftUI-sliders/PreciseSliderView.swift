//
//  PreciseSlider.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 01.02.2022.
//

import SwiftUI

struct PreciseSliderView: View {
    @ObservedObject var viewModel = PreciseSliderViewModel()

    // TODO: Dynamické rozměry komponenty
    // TODO: DataSource/Delegate rozhraní
    var body: some View {
        ZStack {
            // Pozadí
            Rectangle().frame(width: 360, height: 50, alignment: .center).foregroundColor(Color.black)
            //
            ForEach(0..<viewModel.numberOfUnits) { index in
                ZStack {
                    Rectangle()
                        .frame(width: 1, height: viewModel.getUnitHeight(ofIndex: index), alignment: .leading)
                        .foregroundColor(getUnitColor(ofIndex: index))
                        .opacity(viewModel.getUnitOpacity(ofIndex: index))
                    //
                    Text(getUnitLabel(ofIndex: index))
                        .background(Color.black)
                        .font(Font.system(size:7, design: .rounded))
                        .foregroundColor(getUnitColor(ofIndex: index))
                        .opacity(viewModel.getUnitOpacity(ofIndex: index))
                        .frame(width:
                                viewModel.truncScale < 1.15 ?
                               5 * viewModel.designUnit :
                                (viewModel.truncScale < 3.0 ? viewModel.designUnit * 2 : viewModel.designUnit),
                               height: 15)
                }
                .offset(viewModel.getUnitOffset(ofIndex: index))
            }
            // Středový bod
            Rectangle().frame(width: 1, height: 40).foregroundColor(.blue)
        }
        // Výběr hodnoty
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let newValue = viewModel.prevValue - (gesture.translation.width / viewModel.scale)
                    
                    if viewModel.isInfinite ||
                        (newValue <= viewModel.maxValue &&
                         newValue >= viewModel.minValue) {
                        viewModel.value = newValue
                    }
                    else {
                        viewModel.value = newValue > viewModel.maxValue ?
                        viewModel.maxValue : viewModel.minValue
                    }
                }
                .onEnded { _ in
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
    }
    
    // TODO: Uživatelský vstup - DataSource
    private func getUnitLabel(ofIndex index: Int) -> String {
        if viewModel.truncScale > 3.0 ||
            viewModel.getRelativeIndex(ofIndex: index) % 5 == 0 {
            return String(viewModel.getUnitValue(ofIndex: index))
        }
        //
        return ""
    }
    
    // TODO: Uživatelský vstup - DataSource
    private func getUnitColor(ofIndex index: Int) -> Color {
        return .white
    }
}

struct PreciseSliderView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderView()
    }
}
