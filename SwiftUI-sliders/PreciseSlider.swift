//
//  PreciseSlider.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 01.02.2022.
//

import SwiftUI

struct PreciseSlider: View {
    @State var value: Double = 0.0
    @State var scale: Double = 1.0
    
    private let numberOfUnits: Int = 41
    private let defaultStep: CGFloat = 10.0
    
    private var designUnit: CGFloat {
        return CGFloat(defaultStep) * scale
    }
    
    private var middleIndex: Int {
        return (numberOfUnits / 2) + 1
    }
    
    var body: some View {
        ZStack {
            Rectangle().frame(width: 400, height: 50, alignment: .center).foregroundColor(Color.black)
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
                }
                .offset(getUnitOffset(ofIndex: index))
            }
        }
    }
    
    private func getUnitHeight(ofIndex index: Int) -> CGFloat {
        return 15.0
    }
    
    private func getUnitOffset(ofIndex index: Int) -> CGSize {
        let offset = (CGFloat(index) * designUnit) - (CGFloat(middleIndex) * designUnit)
        
        return .init(width: offset, height: .zero)
    }
    
    private func getUnitOpacity(ofIndex index: Int) -> Double {
        return 1.0
    }
    
    private func getUnitColor(ofIndex index: Int) -> Color {
        return .white
    }
    
    private func getUnitLabel(ofIndex index: Int) -> String {
        return ""
    }
}

struct PreciseSlider_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSlider()
    }
}
