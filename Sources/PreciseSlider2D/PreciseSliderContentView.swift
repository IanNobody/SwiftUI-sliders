//
//  SwiftUIView.swift
//  
//
//  Created by Šimon Strýček on 26.03.2022.
//

import SwiftUI

struct PreciseSliderContentView<Content: View>: View, Animatable {
    @Environment(\.preciseSlider2DStyle) var style
    
    var animatableData: CGSize
    let scale: CGSize
    var offset: CGSize {
        animatableData
    }
    let isXInfinite: Bool
    let isYInfinite: Bool
    let content: (_ size: CGSize, _ scale: CGSize) -> Content
    
    init(scale: CGSize, offset: CGSize, isXInfinite: Bool, isYInfinite: Bool, content: @escaping (_ size: CGSize, _ scale: CGSize) -> Content) {
        self.animatableData = offset
        self.scale = scale
        self.isXInfinite = isXInfinite
        self.isYInfinite = isYInfinite
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<(isYInfinite ? 4 : 1), id: \.self) { _ in
                        HStack(spacing: 0) {
                            ForEach(0..<(isXInfinite ? 4 : 1), id: \.self) { _ in
                                content(geometry.size, scale)
                                    .frame(
                                        width: geometry.size.width,
                                        height: geometry.size.width
                                    )
                                    .clipShape(Rectangle())
                            }
                        }
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.width
                )
                .offset(
                    x: truncOffset(to: geometry.size).width,
                    y: truncOffset(to: geometry.size).height
                )
                .scaleEffect(scale)
                
                switch(style.pointerColor) {
                case .invertedColor:
                    Rectangle()
                        .frame(width: 1, height: style.pointerSize.height)
                        .overlay(
                            VStack(spacing: 0) {
                                ForEach(0..<(isYInfinite ? 4 : 1), id: \.self) { _ in
                                    HStack(spacing: 0) {
                                        ForEach(0..<(isXInfinite ? 4 : 1), id: \.self) { _ in
                                            content(geometry.size, scale)
                                                .frame(
                                                    width: geometry.size.width,
                                                    height: geometry.size.width
                                                )
                                                .clipShape(Rectangle())
                                        }
                                    }
                                }
                            }
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.width
                            )
                            .offset(
                                x: truncOffset(to: geometry.size).width,
                                y: truncOffset(to: geometry.size).height
                            )
                            .scaleEffect(scale)
                        )
                        .clipShape(Rectangle())
                        .colorInvert()
                    Rectangle()
                        .frame(width: style.pointerSize.width, height: 1)
                        .overlay(
                            VStack(spacing: 0) {
                                ForEach(0..<(isYInfinite ? 4 : 1), id: \.self) { _ in
                                    HStack(spacing: 0) {
                                        ForEach(0..<(isXInfinite ? 4 : 1), id: \.self) { _ in
                                            content(geometry.size, scale)
                                                .frame(
                                                    width: geometry.size.width,
                                                    height: geometry.size.width
                                                )
                                                .clipShape(Rectangle())
                                        }
                                    }
                                }
                            }
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.width
                            )
                            .offset(
                                x: truncOffset(to: geometry.size).width,
                                y: truncOffset(to: geometry.size).height
                            )
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
                            .foregroundColor(style.axisBackgroundColor)
                        //
                        VStack(spacing: 0) {
                            ForEach(0..<(isYInfinite ? 3 : 1), id: \.self) { _ in
                                HStack(spacing: 0) {
                                    ForEach(0..<(isXInfinite ? 3 : 1), id: \.self) { _ in
                                        content(geometry.size, scale)
                                            .frame(
                                                width: geometry.size.width,
                                                height: geometry.size.width
                                            )
                                            .clipShape(Rectangle())
                                    }
                                }
                            }
                        }
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.width
                        )
                        .offset(
                            x: truncOffset(to: geometry.size).width * 0.5,
                            y: truncOffset(to: geometry.size).height * 0.5
                        )
                        .scaleEffect(
                            CGSize(
                                width: scale.width * 1.3,
                                height: scale.height * 1.3)
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
        .drawingGroup()
    }
    
    func truncOffset(to frameSize: CGSize) -> CGSize {
        CGSize(
            width: offset.width,//offset.width.truncatingRemainder(dividingBy: frameSize.width),
            height: offset.height//offset.height.truncatingRemainder(dividingBy: frameSize.height)
        )
    }
}


struct PreciseSliderContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseSliderContentView(
            scale: CGSize(width: 1, height: 1),
            offset: CGSize(width: -100, height: -10),
            isXInfinite: false,
            isYInfinite: false,
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
    }
}
