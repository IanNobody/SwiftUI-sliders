//
//  SwiftUIView.swift
//  
//
//  Created by Šimon Strýček on 26.03.2022.
//

import SwiftUI

struct PreciseContent2DView<Content: View>: View, Animatable {
    @Environment(\.preciseSlider2DStyle) var style

    //
    var animatableData: AnimatablePair<CGFloat, CGFloat>
    let scale: CGSize
    var offset: AnimatablePair<CGFloat, CGFloat> {
        animatableData
    }
    let isXInfinite: Bool
    let isYInfinite: Bool
    let content: (_ size: CGSize, _ scale: CGSize) -> Content

    //
    init(
        scale: CGSize,
        offset: AnimatablePair<CGFloat, CGFloat>,
        isXInfinite: Bool,
        isYInfinite: Bool,
        content: @escaping (_ size: CGSize, _ scale: CGSize) -> Content
    ) {
        self.animatableData = offset
        self.scale = scale
        self.isXInfinite = isXInfinite
        self.isYInfinite = isYInfinite
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vizualizace
                ZStack {
                    ContentView(isXInfinite: isXInfinite, isYInfinite: isYInfinite) {
                        content(geometry.size, scale)
                    }
                    .scaleEffect(scale)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .offset(
                    x: truncOffset(by: geometry.size).width * scale.width,
                    y: truncOffset(by: geometry.size).height * scale.height
                )

                // Středový ukazatel
                switch style.pointerColor {
                case .invertedColor:
                    Rectangle()
                        .frame(width: 1, height: style.pointerSize.height)
                        .overlay(
                            ZStack {
                                ContentView(isXInfinite: isXInfinite, isYInfinite: isYInfinite) {
                                    content(geometry.size, scale)
                                }
                                .scaleEffect(scale)
                            }
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .offset(
                                x: truncOffset(by: geometry.size).width * scale.width,
                                y: truncOffset(by: geometry.size).height * scale.height
                            )
                        )
                        .clipShape(Rectangle())
                        .colorInvert()
                    Rectangle()
                        .frame(width: style.pointerSize.width, height: 1)
                        .overlay(
                            ZStack {
                                ContentView(isXInfinite: isXInfinite, isYInfinite: isYInfinite) {
                                    content(geometry.size, scale)
                                }
                                .scaleEffect(scale)
                            }
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .offset(
                                x: truncOffset(by: geometry.size).width * scale.width,
                                y: truncOffset(by: geometry.size).height * scale.height
                            )
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
                // Pozadí obsahu
                if !isXInfinite || !isYInfinite {
                    switch style.background {
                    case .blurredContent:
                        ZStack {
                            Rectangle()
                                .foregroundColor(style.axisBackgroundColor)
                            //
                            ZStack {
                                ContentView(isXInfinite: isXInfinite, isYInfinite: isYInfinite) {
                                    content(geometry.size, scale)
                                }
                                .scaleEffect(
                                    CGSize(
                                        width: scale.width * 1.3,
                                        height: scale.height * 1.3)
                                )
                            }
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .offset(
                                x: truncOffset(by: geometry.size).width * 0.5 * scale.width,
                                y: truncOffset(by: geometry.size).height * 0.5 * scale.height
                            )
                            .blur(radius: 50)
                            .brightness(-0.3)
                        }
                    case .color(let color):
                        Rectangle()
                            .foregroundColor(color)
                    }
                }
                else {
                    Rectangle()
                        .foregroundColor(.black)
                }
            })
            .clipShape(Rectangle())
        }
        .drawingGroup()
    }

    func minValue(from size: CGFloat) -> CGFloat {
        -(size / 2)
    }

    func maxValue(from size: CGFloat) -> CGFloat {
        (size / 2)
    }

    func truncOffset(by frameSize: CGSize) -> CGSize {
        var x = (offset.first + maxValue(from: frameSize.width)).truncatingRemainder(dividingBy: frameSize.width)
        var y = (offset.second + maxValue(from: frameSize.height)).truncatingRemainder(dividingBy: frameSize.height)

        if x > 0 {
            x += minValue(from: frameSize.width)
        }
        else {
            x += maxValue(from: frameSize.width)
        }

        if y > 0 {
            y += minValue(from: frameSize.height)
        }
        else {
            y += maxValue(from: frameSize.height)
        }

        return CGSize(
            width: (isXInfinite ? x - frameSize.width : offset.first),
            height: (isYInfinite ? y - frameSize.height : offset.second)
        )
    }
}

private struct ContentView<Content: View>: View {
    let isXInfinite: Bool
    let isYInfinite: Bool

    //
    let content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<(isYInfinite ? 3 : 1), id: \.self) { _ in
                    HStack(spacing: 0) {
                        ForEach(0..<(isXInfinite ? 3 : 1), id: \.self) { _ in
                            content()
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .clipShape(Rectangle())
                        }
                    }
                }
            }
            .offset(y: 0)
        }
    }
}

struct PreciseSliderContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreciseContent2DView(
            scale: CGSize(width: 1, height: 1),
            offset: AnimatablePair(-1234, 0),
            isXInfinite: true,
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
                .border(.red)
            }
        )
    }
}
