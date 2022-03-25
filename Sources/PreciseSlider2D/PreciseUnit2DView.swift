//
//  PreciseUnit2DView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 16.03.2022.
//

import SwiftUI

struct PreciseUnit2DView<ValueLabel: View>: View {
    let isActive: Bool
    let unitHeight: CGFloat
    let hasValue: Bool
    @ViewBuilder let valueLabel: () -> ValueLabel
    
    // TODO: Volitelné barvy
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if isActive {
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                        .border(.blue)
                }
                
                Rectangle()
                    .frame(maxWidth: 1, maxHeight: unitHeight)
                    .foregroundColor(.white)
                
                if hasValue {
                    valueLabel()
                        .frame(
                            width: geometry.size.width,
                            height: (geometry.size.height * 0.9) - unitHeight
                    )
                    .opacity(isActive ? 1.0 : 0.0)
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: isActive ? .top : .center
            )
        }
    }
}

struct PreciseUnit2DView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseUnit2DView(isActive: true, unitHeight: 15, hasValue: true, valueLabel: {
            Text("100")
                .font(.system(size: 5))
                .rotationEffect(.degrees(-90))
        })
        .frame(width: 20, height: 40, alignment: .center)
    }
}
