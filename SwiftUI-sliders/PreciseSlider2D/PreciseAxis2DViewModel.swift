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
    
    // TODO: Použít tuto logiku na 1D variantě a odebrat override.
    // Posuv osy v rámci jedné jednotky
    override var offset: CGFloat {
        return (value / unit) * designUnit
    }
    
    override func unitOffset(forIndex index: Int) -> CGFloat {
        return (
            (CGFloat(index) * designUnit)
            - offset
        )
    }
    
    override func relativeIndex(forIndex index: Int) -> Int {
        index
    }
    
    override func unitHeight(forIndex index: Int) -> CGFloat {
        super.unitHeight(forIndex: index) / 2
    }
}
