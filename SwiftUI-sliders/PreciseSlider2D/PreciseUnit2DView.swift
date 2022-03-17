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
    @ViewBuilder let valueLabel: () -> ValueLabel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Rectangle()
                    .frame(width: 1, height: unitHeight)
                    .foregroundColor(.white)
                
                valueLabel()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height - unitHeight
                    )
                    .background(.black)
                    .opacity(isActive ? 1.0 : 0.0)
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
        PreciseUnit2DView(isActive: true, unitHeight: 10, valueLabel: {
            Text("100")
                .font(.system(size: 9))
                .foregroundColor(.white)
                .rotationEffect(.degrees(-90))
        })
        .frame(width: 40, height: 40, alignment: .center)
    }
}
