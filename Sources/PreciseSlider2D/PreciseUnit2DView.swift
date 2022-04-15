//
//  PreciseUnit2DView.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 16.03.2022.
//

import SwiftUI

struct PreciseUnit2DView<ValueLabel: View>: View {
    @Environment(\.preciseSlider2DStyle) var style

    //
    let isActive: Bool
    let unitHeight: CGFloat
    let isHighlited: Bool
    let color: Color
    //
    @ViewBuilder let valueLabel: () -> ValueLabel

    //
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Odsazení jednotky od okraje osy
                if isActive {
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                }

                // Čára označující jednotku
                Rectangle()
                    .frame(maxWidth: 1, maxHeight: unitHeight)
                    .foregroundColor(color)

                // Popisek jednotky
                if isHighlited {
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
        PreciseUnit2DView(
            isActive: true,
            unitHeight: 15,
            isHighlited: true,
            color: .white,
            valueLabel: {
                Text("100")
                    .font(.system(size: 5))
                    .rotationEffect(.degrees(-90))
            }
        )
        .frame(width: 20, height: 40, alignment: .center)
    }
}
