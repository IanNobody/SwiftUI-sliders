//
//  UIPreciseSlider.swift
//  
//
//  Created by Šimon Strýček on 06.04.2022.
//

#if !os(macOS)

import UIKit
import SwiftUI
import Combine

public class UIPreciseSlider: UIView {
    @ObservedObject var viewModel = PreciseSliderViewModel()
    public var dataSource: PreciseSliderDataSource?
    private let style = PreciseSliderStyle()
    
    public var axisBackgroundColor: UIColor {
        get {
            UIColor(style.backgroundColor)
        }
        set {
            style.backgroundColor = Color(uiColor: newValue)
        }
    }
    
    public var defaultUnitColor: UIColor {
        get {
            UIColor(style.defaultUnitColor)
        }
        set {
            style.defaultUnitColor = Color(uiColor: newValue)
            
            if !hasHighlitedUnitDifferentColor {
                style.highlightedUnitColor = style.defaultUnitColor
            }
        }
    }
    
    public var hasHighlitedUnitDifferentColor: Bool = false
    
    public var highlightedUnitColor: UIColor {
        get {
            UIColor(style.highlightedUnitColor)
        }
        set {
            if hasHighlitedUnitDifferentColor {
                style.highlightedUnitColor = Color(uiColor: newValue)
            }
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
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        reloadView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        reloadView()
    }
    
    public func updateView(with viewModel: PreciseSliderViewModel, with dataSource: PreciseSliderDataSource?) {
        self.viewModel = viewModel
        self.dataSource = dataSource
        
        reloadView()
    }
    
    private var currentSubview: UIView?
    
    private func initSlider() {
        let slider = UIHostingController(
            rootView:
                PreciseSliderView(
                    viewModel: self.viewModel,
                    valueLabel: { value, step in
                        Text(self.dataSource?.unitLabelText(for: value, with: step) ?? "")
                            .foregroundColor(Color(self.dataSource?.unitLabelColor(for: value, with: step) ?? .white))
                            .font(Font((self.dataSource?.unitLabelFont(for: value, with: step) ?? UIFont.systemFont(ofSize: 6)) as CTFont))
                    }
                )
                .preciseSliderStyle(style)
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
}

#endif
