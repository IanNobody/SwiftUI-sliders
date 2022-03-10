//
//  PreciseAxisViewModel.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 16.02.2022.
//

import Foundation
import SwiftUI

class PreciseAxis2DViewModel: PreciseSliderViewModel {
    @Published var active: Bool = false
    
    func activeMove(byValue difference: CGFloat) {
        withAnimation(.easeInOut) {
            active = true
        }
        
        super.move(byValue: difference)
    }
    
    override func animateMomentum(byValue difference: CGFloat, duration: CGFloat) {
        if active {
            withAnimation(.easeInOut.delay(2)) {
                active = false
            }
        }
        
        super.animateMomentum(byValue: difference, duration: duration)
    }
}
