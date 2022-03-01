//
//  PreciseSlider2DViewModel.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 15.02.2022.
//

import Foundation

class PreciseSlider2DViewModel: ObservableObject {
    @Published var valueX: Double = Double.zero
    @Published var valueY: Double = Double.zero
    
    @Published var scaleX: Double = 1.0
    @Published var scaleY: Double = 1.0
    
    public let numberOfUnits: Int = 30
}
