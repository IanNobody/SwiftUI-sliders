//
//  PreciseSlider.swift
//  SwiftUI-sliders
//
//  Created by Šimon Strýček on 01.02.2022.
//

import SwiftUI

struct PreciseSliderView: View {
    @ObservedObject var viewModel = PreciseSliderViewModel()
    
    // TODO: Rozdělit rozhraní pro UIKit a SwiftUI elegantnějším způsobem
    // TODO: Proč musí View vědět o DataSource a Delegate?
    public var dataSource: PreciseSliderDataSource? {
        get {
            return viewModel.dataSource
        }
        set {
            viewModel.dataSource = newValue
        }
    }
    
    //
    public var delegate: PreciseSliderDelegate? {
        get {
            return viewModel.delegate
        }
        set {
            viewModel.delegate = newValue
        }
    }
    
    // TODO: Dynamické rozměry komponenty
    // TODO: Vyřešit chyby vzniklé nedokončenými gesty (nevyvolání události .onEnded)
    // TODO: Vyřešit nekonečnost osy (aktuálně hrozí přetečení relativního indexu)
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadí
                Rectangle()
                .foregroundColor(dataSource?.backgroundColor ?? .black)
                //
                ZStack {
                    ForEach(0..<numberOfUnits(fromWidth: geometry.size.width)) { index in
                        ZStack {
                            if isUnitVisible(ofIndex: index, withWidth: geometry.size.width)
                            {
                                Rectangle()
                                    .frame(width: 1, height: unitHeight(forIndex: index, withWidth: geometry.size.width), alignment: .leading)
                                    .foregroundColor(unitColor(forIndex: index, withWidth: geometry.size.width))
                                //
                                unitLabel(forIndex: index, withWidth: geometry.size.width)
                                    .background(Color.black)
                                    .font(Font.system(size:7, design: .rounded))
                                    .foregroundColor(dataSource?.unitColor(forValue: unitValue(forIndex: index, withWidth: geometry.size.width), forIndex: relativeIndex(forIndex: index, withWidth: geometry.size.width)) ?? .white)
                                    .frame(width:
                                            viewModel.truncScale < 1.15 ?
                                           5 * viewModel.designUnit :
                                            (viewModel.truncScale < 3.0 ? viewModel.designUnit * 2 : viewModel.designUnit),
                                           height: 15)
                            }
                        }.offset(x: normalizedOffset(fromOffset: viewModel.unitOffset(forIndex: index), withWidth: geometry.size.width))
                    }
                }
                // Středový bod
                Rectangle().frame(width: 1, height: 40).foregroundColor(.blue)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.width / 8
            )
        }
        .clipShape(Rectangle())
        // Výběr hodnoty
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    viewModel.interruptAnimation()
                    
                    viewModel.move(byValue: gesture.translation.width)
                }
                .onEnded { gesture in
                    viewModel.animateMomentum(byValue: (gesture.translation.width - gesture.predictedEndTranslation.width) / viewModel.scale)

                    viewModel.editingValueEnded()
                }
        )
        // Výběr měřítka
        .gesture(
            MagnificationGesture()
                .onChanged { gesture in
                    viewModel.interruptAnimation()
                    
                    let newScale = viewModel.prevScale * gesture.magnitude
                    
                    // Ošetření minimální hodnoty
                    viewModel.scale = newScale > 1 ? newScale : 1.0
                }
                .onEnded { _ in
                    viewModel.editingScaleEnded()
                }
        )
        // TODO: Zastavení animace jinými gesty
    }
    
    private func maxUnitHeight(fromWidth width: CGFloat) -> CGFloat {
        return axisHeight(fromFrameWidth: width) / 2
    }
    
    private func numberOfUnits(fromWidth width: CGFloat) -> Int {
        let num = Int(ceil(width / CGFloat(viewModel.defaultStep)))
        
        // Zaokrouhlení k nejbližšímu vyššímu násobku 5
        // (5 = počet dílků jedné jednotky)
        let base = (num / 5) + 1
        
        //
        if base % 2 == 0 {
            return base * 5
        }
        else {
            return (base + 1) * 5
        }
    }
    
    private func middleIndex(fromWidth width: CGFloat) -> Int {
        return Int(numberOfUnits(fromWidth: width) / 2)
    }
    
    // Index jednotky s ohledem na zvolenou hodnotu
    public func relativeIndex(forIndex index: Int, withWidth width: CGFloat) -> Int {
        
        let indexOffset = index - Int(viewModel.value / viewModel.unit)
        
        // Zaokrouhlení k nejbližšímu nižšímu násobku celkového počtu jednotek
        let roundedOffset = Int(floor(
            Float(indexOffset)
            / Float(numberOfUnits(fromWidth: width))
        )) * numberOfUnits(fromWidth: width)

        return index - roundedOffset
    }
    
    private func maximumUnitOffset(fromWidth width: CGFloat) -> CGFloat {
        return CGFloat(numberOfUnits(fromWidth: width)) * viewModel.designUnit
    }
    
    private func normalizedOffset(fromOffset offset: CGFloat, withWidth width: CGFloat) -> CGFloat {
        let max = maximumUnitOffset(fromWidth: width)
        
        let scaleCorrection = viewModel.designUnit * CGFloat(middleIndex(fromWidth: width))
        
        if offset > max {
            return (offset.truncatingRemainder(dividingBy: max) - scaleCorrection)
        }
        
        if offset < 0 {
            return max + (offset.truncatingRemainder(dividingBy: max) - scaleCorrection)
        }
        
        return (offset - scaleCorrection)
    }
    
    //
    
    // TODO: Vyřešit zaokrouhlovací chyby
    public func unitValue(forIndex index: Int, withWidth width: CGFloat) -> Double {
        return (
            viewModel.value
            - (viewModel.offset / viewModel.designUnit * viewModel.unit)
            + (viewModel.unit * Double(relativeIndex(forIndex: index, withWidth: width) - middleIndex(fromWidth: width)))
        )
    }
    
    public func unitHeight(forIndex index: Int, withWidth width: CGFloat) -> CGFloat {
        return viewModel.unitHeightRatio(forIndex: relativeIndex(forIndex: index, withWidth: width)) * maxUnitHeight(fromWidth: width)
    }

    private func axisHeight(fromFrameWidth frame: CGFloat) -> CGFloat {
        return frame / 6
    }
    
    private func unitLabel(forIndex index: Int, withWidth width: CGFloat) -> Text {
        let unitValue = unitValue(forIndex: index, withWidth: width)
        
        if let label = dataSource?.unitLabel(forValue: unitValue) {
            return label
        }
        else {
            return defaultUnitLabel(forIndex: index, withWidth: width)
        }
    }
    
    private func defaultUnitLabel(forIndex index: Int, withWidth width: CGFloat) -> Text {
        if viewModel.truncScale > 3.0 ||
            relativeIndex(forIndex: index, withWidth: width) % 5 == 0 {
            return Text(String(unitValue(forIndex: index, withWidth: width)))
        }
        //
        return Text("")
    }
    
    private func unitColor(forIndex index: Int, withWidth width: CGFloat) -> Color {
        return dataSource?.unitColor(
            forValue: unitValue(forIndex: index, withWidth: width),
            forIndex: relativeIndex(forIndex: index, withWidth: width)
        ) ?? .white
    }
    
    public func isUnitVisible(ofIndex index: Int, withWidth width: CGFloat) -> Bool {
        if (unitValue(forIndex: index, withWidth: width) > viewModel.maxValue ||
            unitValue(forIndex: index, withWidth: width) < viewModel.minValue) &&
            !viewModel.isInfinite {
            return false
        }
        else {
            return true
        }
    }
}

struct PreciseSliderView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderView()
    }
}
