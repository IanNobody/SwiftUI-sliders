//
//  PreciseSliderUnitView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 15.03.2022.
//

import SwiftUI

struct PreciseSliderUnitView<UnitLabel: View>: View {
    @ViewBuilder let unitLabel: () -> UnitLabel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(.white)
                unitLabel()
                    // TODO: Volba vlastní barvy
                    .background(.black)
                    .frame(height: geometry.size.height / 3)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
    }
}

struct PreciseSliderUnitView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderUnitView(unitLabel: {
            Text("0")
                .foregroundColor(.white)
        })
    }
}
