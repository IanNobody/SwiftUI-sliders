//
//  PreciseSlider.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 01.02.2022.
//

import SwiftUI

struct PreciseSlider: View {
    @State var value: Double = 0.0
    @State var prevValue: Double = 0.0
        
    @State var scale: Double = 1.0
    @State var prevScale: Double = 1.0
    
    private var truncScale: Double {
        return scale / scaleBase
    }
    
    private var scaleBase: Double {
        let exponent = floor(log(scale) / log(5))
        return pow(5, exponent)
    }
    
    // Počet jednotek osy
    private let numberOfUnits: Int = 41
    // Výchozí vzdálenost mezi jednotkami
    private let defaultStep: CGFloat = 10.0
    // Meze posuvníku
    private let isInfinite: Bool = false
    private let maxValue: Double = 1000.0
    private let minValue: Double = -1000.0
    
    // Reálná hodnota zobrazené jednotky
    private var unit: CGFloat {
        return Double(defaultStep) / scaleBase
    }
    
    // Grafická vzdálenost jedné jednotky
    private var designUnit: CGFloat {
        return CGFloat(defaultStep) * truncScale
    }
    
    // Index středu osy
    private var middleIndex: Int {
        return (numberOfUnits / 2) + 1
    }
    
    // Posuv osy v rámci jedné jednotky
    private var offset: CGFloat {
        var truncValue = value.truncatingRemainder(dividingBy: unit)
        
        // Oprava nepřesností
        if (unit - truncValue) < (unit / 1000) {
            truncValue = 0
        }

        // Transformace do báze vizualizace
        return (truncValue / unit) * designUnit
    }
    
    var body: some View {
        ZStack {
            // Pozadí
            Rectangle().frame(width: 360, height: 50, alignment: .center).foregroundColor(Color.black)
            //
            ForEach(0..<numberOfUnits) { index in
                ZStack {
                    Rectangle()
                        .frame(width: 1, height: getUnitHeight(ofIndex: index), alignment: .leading)
                        .foregroundColor(getUnitColor(ofIndex: index))
                        .opacity(getUnitOpacity(ofIndex: index))
                    //
                    Text(getUnitLabel(ofIndex: index))
                        .background(Color.black)
                        .font(Font.system(size:7, design: .rounded))
                        .foregroundColor(getUnitColor(ofIndex: index))
                        .opacity(getUnitOpacity(ofIndex: index))
                        .frame(width:
                                truncScale < 1.15 ?
                                    5 * designUnit :
                                (truncScale < 3.0 ? designUnit * 2 : designUnit),
                               height: 15)
                }
                .offset(getUnitOffset(ofIndex: index))
            }
            // Středový bod
            Rectangle().frame(width: 1, height: 30).foregroundColor(.blue)
        }
        // Výběr hodnoty
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let newValue = prevValue - (gesture.translation.width / scale)
                    
                    if isInfinite ||
                        (newValue <= maxValue &&
                        newValue >= minValue) {
                        value = newValue
                    }
                    else {
                        value = newValue > maxValue ?
                        maxValue : minValue
                    }
                }
                .onEnded { _ in
                    prevValue = value
                }
        )
        // Výběr měřítka
        .gesture(
            MagnificationGesture()
                .onChanged { gesture in
                    let newScale = prevScale * gesture.magnitude
                    
                    // Ošetření minimální hodnoty
                    scale = newScale > 1 ? newScale : 1.0
                }
                .onEnded { _ in
                    prevScale = scale
                }
        )
    }
    
    private func getUnitHeight(ofIndex index: Int) -> CGFloat {
        if getRelativeIndex(ofIndex: index) % 5 != 0 {
            let height = (truncScale - 1) / 3 * 20
            return height < 20.0 ? height : 20.0
        }
        //
        return 20.0
    }
    
    private func getUnitOffset(ofIndex index: Int) -> CGSize {
        let offset = (CGFloat(index) * designUnit) - (CGFloat(middleIndex) * designUnit) - offset
        
        return .init(width: offset, height: .zero)
    }
        
    private func getUnitValue(ofIndex index: Int) -> Double {
        return (value - (offset / designUnit * unit) + (unit * Double(index - middleIndex)))
    }
    
    private func getUnitLabel(ofIndex index: Int) -> String {
        if truncScale > 3.0 ||
            getRelativeIndex(ofIndex: index) % 5 == 0 {
            return String(getUnitValue(ofIndex: index))
        }
        //
        return ""
    }
    
    private func getRelativeIndex(ofIndex index: Int) -> Int {
        return index
            + Int((value / unit)
                    .truncatingRemainder(dividingBy: 5))
            - Int(middleIndex % 5)
    }
    
    // Nepoužito
    private func getUnitOpacity(ofIndex index: Int) -> Double {
        if (getUnitValue(ofIndex: index) > maxValue ||
            getUnitValue(ofIndex: index) < minValue) &&
            !isInfinite {
            return 0.0
        }
        else {
            return 1.0
        }
    }
    
    // Nepoužito
    private func getUnitColor(ofIndex index: Int) -> Color {
        return .white
    }
}

struct PreciseSlider_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSlider()
    }
}
