//
//  ColorPickerModal.swift
//  ColorPickerExample-SwiftUI
//
//  Created by Šimon Strýček on 05.04.2022.
//

import SwiftUI
import PreciseSlider2D

struct ColorPickerModal: View {
    @ObservedObject private var hueAxis: PreciseAxis2DViewModel
    @ObservedObject private var saturationAxis: PreciseAxis2DViewModel
    public var completition: ((_ hue: Double, _ saturation: Double) -> ())?
    
    @Binding var isShowing: Bool
    
    public init(defaultHue: Double, defaultSaturation: Double, isShowing: Binding<Bool>, completition: ((_ hue: Double, _ saturation: Double) -> ())?) {
        hueAxis = PreciseAxis2DViewModel(
            defaultValue: defaultHue,
            maxValue: 360,
            minScale: 0.5,
            maxScale: 10,
            numberOfUnits: 10
        )
        
        saturationAxis = PreciseAxis2DViewModel(
            defaultValue: defaultSaturation,
            maxValue: 100,
            minScale: 0.5,
            maxScale: 10,
            numberOfUnits: 10
        )
        
        self._isShowing = isShowing
        self.completition = completition
    }
    
    var body: some View {
        ZStack {
            if isShowing {
                Color.black.ignoresSafeArea().opacity(0.75)
                    .gesture(
                        TapGesture()
                            .onEnded {
                                isShowing = false
                            }
                    )
                //
                VStack(spacing: 20) {
                    PreciseSlider2DView(
                        axisX: hueAxis,
                        axisY: saturationAxis,
                        content: { size, scale in
                            Rectangle()
                                .fill (
                                    LinearGradient(
                                        colors: [
                                            Color(hue: 0, saturation: 1, brightness: 1),
                                            Color(hue: 60/360, saturation: 1, brightness: 1),
                                            Color(hue: 120/360, saturation: 1, brightness: 1),
                                            Color(hue: 180/360, saturation: 1, brightness: 1),
                                            Color(hue: 240/360, saturation: 1, brightness: 1),
                                            Color(hue: 300/360, saturation: 1, brightness: 1),
                                            Color(hue: 1, saturation: 1, brightness: 1)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hue: 0, saturation: 0, brightness: 1),
                                                    Color(hue: 0, saturation: 0, brightness: 1)
                                                        .opacity(0)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                }
                        },
                        axisXLabel: { value,step in
                            Text("\(formatLabelValue(value))")
                                .font(.system(size: 7))
                                .foregroundColor(.white)
                        },
                        axisYLabel: { value,step in
                            Text("\(formatLabelValue(value))")
                                .font(.system(size: 7))
                                .foregroundColor(.white)
                        })
                    .frame(width: 320, height: 320)
                    
                    Button("Hotovo") {
                        completition?(hueAxis.value, saturationAxis.value)
                        isShowing = false
                    }
                    .font(.system(size: 12))
                    .padding(8)
                    .background(.tint)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .animation(Animation.easeInOut, value: isShowing)
    }
    
    private func formatLabelValue(_ value: Double) -> String {
        String(round(abs(value) * 100) / 100)
    }
}

struct ColorPickerModal_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerModal(
            defaultHue: 180,
            defaultSaturation: 50,
            isShowing: State(initialValue: true).projectedValue
        ) { _, _ in
        
        }
    }
}