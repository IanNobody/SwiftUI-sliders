//
//  PreciseSlider2D.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 15.02.2022.
//

import SwiftUI

struct PreciseSlider2D: View {
    @ObservedObject var viewModel = PreciseSlider2DViewModel()
    
    @ObservedObject var axisX = PreciseAxis2DViewModel()
    @ObservedObject var axisY = PreciseAxis2DViewModel()
    
    @State var xActive = false
    @State var yActive = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 300.0, height: 300.0, alignment: .topLeading)
                .foregroundColor(.gray)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        axisX.active = true
                        axisY.active = true
                    }
                    
                    withAnimation(.easeInOut.delay(2)) {
                        axisX.active = false
                        axisY.active = false
                    }
                }
            
            // Osa Y
            PreciseAxis2DView(viewModel: axisY)
                .rotationEffect(.degrees(90))
                .offset(x: 145)
            
            // Osa X
            PreciseAxis2DView(viewModel: axisX)
                .offset(y: 145)
        }
        .frame(width: 310, height: 310, alignment: .topLeading)
    }
}

struct PreciseSlider2D_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSlider2D()
    }
}
