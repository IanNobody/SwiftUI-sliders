//
//  PreciseAxisViewModel.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 16.02.2022.
//

import Foundation
import SwiftUI
import PreciseSlider

public class PreciseAxis2DViewModel: PreciseSliderViewModel {
    @Published var active: Bool = false
    var activationTimer: DispatchSourceTimer?

    func activeMove(byValue difference: CGFloat) {
        cancelDeactivation()

        withAnimation(.easeInOut) {
            active = true
        }

        super.move(byValue: difference)
    }

    override public func animateMomentum(byValue difference: CGFloat,
                                         translationCoefitient coefitient: Double,
                                         duration: CGFloat) {
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + 2)
        timer.setEventHandler {
            self.deactivateAxis()
        }
        timer.resume()
        activationTimer = timer

        //
        super.animateMomentum(byValue: difference, translationCoefitient: coefitient, duration: duration)
    }

    private func cancelDeactivation() {
        activationTimer?.cancel()
        activationTimer = nil
    }

    private func deactivateAxis() {
        withAnimation(.easeInOut) {
            active = false
        }
    }
}
