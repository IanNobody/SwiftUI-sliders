//
//  PreciseSliderUnitView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 15.03.2022.
//

import SwiftUI

struct PreciseUnitView<UnitLabel: View>: View {
    @Environment(\.preciseSliderStyle) var style
    let isHighlited: Bool
    @ViewBuilder let unitLabel: () -> UnitLabel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(
                        isHighlited ?
                            style.highlitedUnitColor : style.defaultUnitColor
                    )
                if isHighlited {
                    unitLabel()
                        .background(style.backgroundColor)
                        .frame(height: geometry.size.height / 3)
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
    }
}

struct PreciseUnitView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseUnitView(isHighlited: true) {
            Text("0")
                .foregroundColor(.white)
        }
    }
}
