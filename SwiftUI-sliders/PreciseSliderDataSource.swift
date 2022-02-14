//
//  PreciseSliderDataSource.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 11.02.2022.
//

import Foundation
import UIKit
import SwiftUI

protocol PreciseSliderDataSource: NSObject {
    // Statické vlastnosti
    func preciseSliderInitialValue() -> Double
    func preciseSliderInitialScale() -> Double
    
    func preciseSliderFinity() -> Bool
    func preciseSliderMaximalValue() -> Double
    func preciseSliderMinimalValue() -> Double
    func preciseSliderBackGroundColor() -> Color
    
    // Dynamické vlasnotsti
    func preciseSliderUnitLabel(value forValue: Double) -> Text
    func preciseSliderUnitColor(value forValue: Double, relativeIndex forIndex: Int) -> Color
}
