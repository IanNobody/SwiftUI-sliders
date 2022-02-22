//
//  PreciseSliderDataSource.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 11.02.2022.
//

import Foundation
import UIKit
import SwiftUI

protocol PreciseSliderDataSource: AnyObject {
    // Statické vlastnosti
    var initialValue: Double { get }
    var initialScale: Double { get }
    
    var isFinite: Bool { get }
    var maximumValue: Double { get }
    var minimumValue: Double { get }
    var backgroundColor: Color { get }
    
    // Dynamické vlasnotsti
    func unitLabel(forValue: Double) -> Text
    func unitColor(forValue: Double, forIndex: Int) -> Color
}
