//
//  PreciseSlider.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 01.02.2022.
//

import SwiftUI

struct PreciseSliderView: View {
    @ObservedObject var viewModel = PreciseSliderViewModel()
    
    //
    public var dataSource: PreciseSliderDataSource? {
        get {
            return viewModel.dataSource
        }
        set {
            viewModel.dataSource = newValue
        }
    }
    
    //
    public var delegate: PreciseSliderDelegate? {
        get {
            return viewModel.delegate
        }
        set {
            viewModel.delegate = newValue
        }
    }
    
    // TODO: Dynamické rozměry komponenty
    // TODO: Vyřešit chyby vzniklé nedokončenými gesty (nevyvolání události .onEnded)
    var body: some View {
        ZStack {
            // Pozadí
            Rectangle().frame(width: 360, height: 50, alignment: .center).foregroundColor(dataSource?.preciseSliderBackGroundColor() ?? .black)
            //
            ForEach(0..<viewModel.numberOfUnits) { index in
                ZStack {
                    Rectangle()
                        .frame(width: 1, height: viewModel.getUnitHeight(ofIndex: index), alignment: .leading)
                        .foregroundColor(getUnitColor(ofIndex: index))
                        .opacity(viewModel.getUnitOpacity(ofIndex: index))
                    //
                    getUnitLabel(ofIndex: index)
                        .background(Color.black)
                        .font(Font.system(size:7, design: .rounded))
                        .foregroundColor(dataSource?.preciseSliderUnitColor(value: viewModel.getUnitValue(ofIndex: index), relativeIndex: viewModel.getRelativeIndex(ofIndex: index)) ?? .white)
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
                    viewModel.interruptAnimation()
                    
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
                .onEnded { gesture in
                    viewModel.animateMomentum(byValue: (gesture.translation.width - gesture.predictedEndTranslation.width) / viewModel.scale)
                    
                    viewModel.editingValueEnded()
                }
        )
        // Výběr měřítka
        .gesture(
            MagnificationGesture()
                .onChanged { gesture in
                    viewModel.interruptAnimation()
                    
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
    
    private func getUnitLabel(ofIndex index: Int) -> Text {
        let unitValue = viewModel.getUnitValue(ofIndex: index)
        
        if let label = dataSource?.preciseSliderUnitLabel(value: unitValue) {
            return label
        }
        else {
            return getDefaultUnitLabel(ofIndex: index)
        }
    }
    
    private func getDefaultUnitLabel(ofIndex index: Int) -> Text {
        if viewModel.truncScale > 3.0 ||
            viewModel.getRelativeIndex(ofIndex: index) % 5 == 0 {
            return Text(String(viewModel.getUnitValue(ofIndex: index)))
        }
        //
        return Text("")
    }
    
    private func getUnitColor(ofIndex index: Int) -> Color {
        return dataSource?.preciseSliderUnitColor(
            value: viewModel.getUnitValue(ofIndex: index),
            relativeIndex: viewModel.getRelativeIndex(ofIndex: index)
        ) ?? .white
    }
}

struct PreciseSliderView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderView()
    }
}
