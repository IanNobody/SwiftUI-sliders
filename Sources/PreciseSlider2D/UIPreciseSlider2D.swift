//
//  UIPreciseSlider2D.swift
//  
//
//  Created by Šimon Strýček on 06.04.2022.
//

#if !os(macOS)

import UIKit
import SwiftUI

public class UIPreciseSlider2D: UIView {
    @ObservedObject var axisXViewModel: PreciseAxis2DViewModel = PreciseAxis2DViewModel()
    @ObservedObject var axisYViewModel: PreciseAxis2DViewModel = PreciseAxis2DViewModel()

    public var axisXDataSource: PreciseAxis2DDataSource?
    public var axisYDataSource: PreciseAxis2DDataSource?

    public var dataSource: PreciseSlider2DDataSource?
    private let style = PreciseSlider2DStyle()

    //
    public var axisBackgroundColor: UIColor {
        get {
            UIColor(style.axisBackgroundColor)
        }
        set {
            style.axisBackgroundColor = Color(uiColor: newValue)
        }
    }

    public var axisPointerColor: UIColor {
        get {
            UIColor(style.axisPointerColor)
        }
        set {
            style.axisPointerColor = Color(uiColor: newValue)
        }
    }

    public var unitColor: (_ value: Double, _ isHighlighted: Bool) -> UIColor {
        get {
            { value, isHighlighted in
                UIColor(self.style.unitColor(value, isHighlighted))
            }
        }
        set {
            style.unitColor = { value, isHighlighted in
                Color(uiColor: newValue(value, isHighlighted))
            }
        }
    }

    public var background: PreciseSlider2DStyle.UIPreciseSlider2DBackground {
        get {
            PreciseSlider2DStyle.UIPreciseSlider2DBackground(sliderBackground: style.background)
        }
        set {
            style.background = PreciseSlider2DStyle.PreciseSlider2DBackground(uiSliderBackground: newValue)
        }
    }

    public var pointerColor: PreciseSlider2DStyle.UIPreciseSlider2DPointerColor {
        get {
            PreciseSlider2DStyle.UIPreciseSlider2DPointerColor(pointerColor: style.pointerColor)
        }
        set {
            style.pointerColor = PreciseSlider2DStyle.PreciseSlider2DPointerColor(uiPointerColor: newValue)
        }
    }

    public var pointerSize: CGSize {
        get {
            style.pointerSize
        }
        set {
            style.pointerSize = newValue
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        reloadView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        reloadView()
    }

    public func updateView(axisXViewModel: PreciseAxis2DViewModel,
                           axisYViewModel: PreciseAxis2DViewModel,
                           axisXDataSource: PreciseAxis2DDataSource?,
                           axisYDataSource: PreciseAxis2DDataSource?,
                           dataSource: PreciseSlider2DDataSource?) {
        self.axisXViewModel = axisXViewModel
        self.axisYViewModel = axisYViewModel
        self.axisXDataSource = axisXDataSource
        self.axisYDataSource = axisYDataSource
        self.dataSource = dataSource

        reloadView()
    }

    private var currentSubview: UIView?

    private func initSlider() {
        let slider = UIHostingController(
            rootView:
                PreciseSlider2DView(
                    axisX: axisXViewModel,
                    axisY: axisYViewModel,
                    content: { size, scale in
                        PreciseSlider2DContent(
                            image: self.dataSource?.contentImage(ofSize: size, withScale: scale),
                            frameSize: size
                        )
                    },
                    axisXLabel: { value, step in
                        Text(self.axisXDataSource?.unitLabelText(for: value, with: step) ?? "")
                            .foregroundColor(
                                Color(
                                    self.axisXDataSource?.unitLabelColor(for: value, with: step) ?? .white
                                )
                            )
                            .font(
                                Font((
                                    self.axisXDataSource?.unitLabelFont(for: value, with: step)
                                        ?? UIFont.systemFont(ofSize: 6)
                                ) as CTFont)
                            )
                    },
                    axisYLabel: { value, step in
                        Text(self.axisYDataSource?.unitLabelText(for: value, with: step) ?? "")
                            .foregroundColor(
                                Color(
                                    self.axisYDataSource?.unitLabelColor(for: value, with: step) ?? .white
                                )
                            )
                            .font(
                                Font((
                                    self.axisYDataSource?.unitLabelFont(for: value, with: step)
                                        ?? UIFont.systemFont(ofSize: 6)
                                ) as CTFont)
                            )
                    }
                )
                .preciseSlider2DStyle(style)
        ).view!

        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)

        NSLayoutConstraint.activate([
            slider.widthAnchor.constraint(equalTo: widthAnchor),
            slider.heightAnchor.constraint(equalTo: heightAnchor),
            slider.centerXAnchor.constraint(equalTo: centerXAnchor),
            slider.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        currentSubview = slider
    }

    private func reloadView() {
        currentSubview?.removeFromSuperview()
        initSlider()
    }

    struct PreciseSlider2DContent: View {
        let image: UIImage?
        let frameSize: CGSize

        var body: some View {
            if let image = image {
                Image(uiImage: image)
                    .frame(width: frameSize.width, height: frameSize.height)
            }
            else {
                Rectangle()
                    .foregroundColor(.black)
                    .frame(width: frameSize.width, height: frameSize.height)
            }
        }
    }
}

#endif
