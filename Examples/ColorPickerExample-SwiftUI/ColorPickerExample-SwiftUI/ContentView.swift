//
//  ContentView.swift
//  ColorPickerExample-SwiftUI
//
//  Created by Šimon Strýček on 05.04.2022.
//

import SwiftUI

struct ContentView: View {
    @State var showingPicker = false
    @State var buttonHue: Double = 220/360
    @State var buttonSaturation: Double = 79/100

    var body: some View {
        ZStack {
            Button("Vybrat barvu") {
                showingPicker = true
            }
            .padding(10)
            .foregroundColor(.black)
            .background(buttonColor)
            .cornerRadius(10)

            ColorPickerModal(
                defaultHue: buttonHue * 360,
                defaultSaturation: buttonSaturation * 100,
                isShowing: $showingPicker
            ) { hue, saturation in
                buttonHue = hue / 360
                buttonSaturation = saturation / 100
            }
        }
    }

    var buttonColor: Color {
        Color(hue: buttonHue, saturation: buttonSaturation, brightness: 1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
