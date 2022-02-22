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
            Rectangle().frame(width: 360, height: 50, alignment: .center).foregroundColor(dataSource?.backgroundColor ?? .black)
            //
            ForEach(0..<viewModel.numberOfUnits) { index in
                ZStack {
                    if viewModel.unitVisibility(ofIndex: index)
                    {
                        Rectangle()
                            .frame(width: 1, height: viewModel.unitHeight(forIndex: index), alignment: .leading)
                            .foregroundColor(unitColor(forIndex: index))
                        //
                        unitLabel(forIndex: index)
                            .background(Color.black)
                            .font(Font.system(size:7, design: .rounded))
                            .foregroundColor(dataSource?.unitColor(forValue: viewModel.unitValue(forIndex: index), forIndex: viewModel.relativeIndex(forIndex: index)) ?? .white)
                            .frame(width:
                                    viewModel.truncScale < 1.15 ?
                                   5 * viewModel.designUnit :
                                    (viewModel.truncScale < 3.0 ? viewModel.designUnit * 2 : viewModel.designUnit),
                                   height: 15)
                    }
                }.offset(viewModel.unitOffset(forIndex: index))
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
    
    private func unitLabel(forIndex index: Int) -> Text {
        let unitValue = viewModel.unitValue(forIndex: index)
        
        if let label = dataSource?.unitLabel(forValue: unitValue) {
            return label
        }
        else {
            return defaultUnitLabel(forIndex: index)
        }
    }
    
    private func defaultUnitLabel(forIndex index: Int) -> Text {
        if viewModel.truncScale > 3.0 ||
            viewModel.relativeIndex(forIndex: index) % 5 == 0 {
            return Text(String(viewModel.unitValue(forIndex: index)))
        }
        //
        return Text("")
    }
    
    private func unitColor(forIndex index: Int) -> Color {
        return dataSource?.unitColor(
            forValue: viewModel.unitValue(forIndex: index),
            forIndex: viewModel.relativeIndex(forIndex: index)
        ) ?? .white
    }
}

struct PreciseSliderView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderView()
    }
}
