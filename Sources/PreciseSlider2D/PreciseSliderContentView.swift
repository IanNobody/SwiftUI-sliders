//
//  SwiftUIView.swift
//  
//
//  Created by Šimon Strýček on 26.03.2022.
//

import SwiftUI

struct PreciseSliderContentView<Content: View>: View {
    @Environment(\.preciseSlider2DStyle) var style
    
    let scale: CGSize
    let offset: CGSize
    let content: (_ size: CGSize, _ scale: CGSize) -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                content(geometry.size, scale)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(Rectangle())
                    .offset(x: offset.width, y: offset.height)
                    .scaleEffect(scale)
                
                switch(style.pointerColor) {
                case .invertedColor:
                    Rectangle()
                        .frame(width: 1, height: style.pointerSize.height)
                        .overlay(
                            content(geometry.size, scale)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipShape(Rectangle())
                                .offset(x: offset.width, y: offset.height)
                                .scaleEffect(scale)
                        )
                        .clipShape(Rectangle())
                        .colorInvert()
                    Rectangle()
                        .frame(width: style.pointerSize.width, height: 1)
                        .overlay(
                            content(geometry.size, scale)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipShape(Rectangle())
                                .offset(x: offset.width, y: offset.height)
                                .scaleEffect(scale)
                        )
                        .clipShape(Rectangle())
                        .colorInvert()
                    
                case .staticColor(let color):
                    Rectangle()
                        .frame(width: 1, height: 20)
                        .foregroundColor(color)
                    Rectangle()
                        .frame(width: 20, height: 1)
                        .foregroundColor(color)
                }
            }
            .background(content: {
                switch(style.background) {
                case .blurredContent:
                    ZStack {
                        Rectangle()
                            .foregroundColor(.black)
                        //
                        content(geometry.size, scale)
                            .scaleEffect(
                                CGSize(
                                    width: scale.width * 1.3,
                                    height: scale.height * 1.3)
                            )
                            .offset(
                                x: offset.width * 0.5,
                                y: offset.height * 0.5
                            )
                            .blur(radius: 50)
                            .brightness(-0.3)
                    }
                case .color(let color):
                    Rectangle()
                        .foregroundColor(color)
                }
            })
            .clipShape(Rectangle())
        }
    }
}

struct PreciseSliderContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderContentView(
            scale: CGSize(width: 1, height: 1),
            offset: CGSize(width: 0, height: 0),
            content: { size, _ in
                ZStack {
                    Rectangle()
                        .foregroundColor(.brown)
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(height: size.height / 3)
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: 1, height: 20)
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: 20, height: 1)
                }
            }
        )
        .preciseSlider2DStyle(PreciseSlider2DStyle(pointerColor: .staticColor(.red)))
    }
}
