//
//  PreciseSliderUnitView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 15.03.2022.
//

import SwiftUI

struct PreciseUnitView<UnitLabel: View>: View {
    @Environment(\.preciseSliderStyle) var style
    let isHighlighted: Bool
    let color: Color
    @ViewBuilder let unitLabel: () -> UnitLabel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(color)
                if isHighlighted {
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
        PreciseUnitView(isHighlighted: true, color: .white) {
            Text("0")
                .foregroundColor(.white)
        }
    }
}
