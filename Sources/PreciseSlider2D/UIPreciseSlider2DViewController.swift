//
//  UIPreciseSlider2DViewController.swift
//  
//
//  Created by Šimon Strýček on 01.04.2022.
//

#if !os(macOS)

import UIKit
import SwiftUI
import Combine

public class UIPreciseSlider2DViewController: UIViewController {
    @ObservedObject var axisXViewModel: PreciseAxis2DViewModel = PreciseAxis2DViewModel()
    @ObservedObject var axisYViewModel: PreciseAxis2DViewModel = PreciseAxis2DViewModel()
    
    public var axisXDataSource: PreciseAxis2DDataSource? {
        didSet {
            initAxisXViewModel()
            loadSlider()
        }
    }
    
    public var axisYDataSource: PreciseAxis2DDataSource? {
        didSet {
            initAxisYViewModel()
            loadSlider()
        }
    }
    
    public var dataSource: PreciseSlider2DDataSource? {
        didSet {
            loadSlider()
        }
    }
    
    public var axisXDelegate: PreciseAxis2DDelegate?
    public var axisYDelegate: PreciseAxis2DDelegate?
    
    public var axisXValue: Double {
        get {
            axisXViewModel.value
        }
        set {
            axisXViewModel.move(toValue: newValue)
        }
    }
    
    public var axisXScale: Double  {
        get {
            axisXViewModel.scale
        }
        set {
            axisXViewModel.zoom(toValue: newValue)
        }
    }
    
    public var axisYValue: Double {
        get {
            axisYViewModel.value
        }
        set {
            axisYViewModel.move(toValue: newValue)
        }
    }
    
    public var axisYScale: Double  {
        get {
            axisYViewModel.scale
        }
        set {
            axisYViewModel.zoom(toValue: newValue)
        }
    }
    
    private var valueXPublisher: AnyCancellable?
    private var scaleXPublisher: AnyCancellable?
    private var interactionXPublisher: AnyCancellable?
    
    private var valueYPublisher: AnyCancellable?
    private var scaleYPublisher: AnyCancellable?
    private var interactionYPublisher: AnyCancellable?
    
    private var sliderViewController: UIHostingController<PreciseSlider2DView<PreciseSlider2DContent, Text, Text>>?
    
    private func initSlider() {
        sliderViewController = UIHostingController(
            rootView:
                PreciseSlider2DView(
                    axisX: axisXViewModel,
                    axisY: axisYViewModel,
                    content: { size, scale in
                        PreciseSlider2DContent(image: self.dataSource?.contentImage(ofSize: size, withScale: scale), frameSize: size)
                    },
                    axisXLabel: { value, step in
                        Text(self.axisXDataSource?.unitLabelText(for: value, with: step) ?? "")
                            .foregroundColor(Color(self.axisXDataSource?.unitLabelColor(for: value, with: step) ?? .white))
                            .font(Font((self.axisXDataSource?.unitLabelFont(for: value, with: step) ?? UIFont.systemFont(ofSize: 6)) as CTFont))
                    },
                    axisYLabel: { value, step in
                        Text(self.axisYDataSource?.unitLabelText(for: value, with: step) ?? "")
                            .foregroundColor(Color(self.axisYDataSource?.unitLabelColor(for: value, with: step) ?? .white))
                            .font(Font((self.axisYDataSource?.unitLabelFont(for: value, with: step) ?? UIFont.systemFont(ofSize: 6)) as CTFont))
                    }
                )
        )
    }
    
    private func applyAxisXDelegate() {
        valueXPublisher = axisXViewModel.$value.sink { newValue in
            self.axisXDelegate?.valueDidChange(value: newValue)
        }
        
        scaleXPublisher = axisXViewModel.$scale.sink { newScale in
            self.axisXDelegate?.scaleDidChange(scale: newScale)
        }
        
        interactionXPublisher = axisXViewModel.$isEditing.removeDuplicates().sink { isEditing in
            if isEditing {
                self.axisXDelegate?.didBeginEditing()
            }
            else {
                self.axisXDelegate?.didEndEditing()
            }
        }
    }
    
    private func applyAxisYDelegate() {
        valueYPublisher = axisYViewModel.$value.sink { newValue in
            self.axisYDelegate?.valueDidChange(value: newValue)
        }
        
        scaleYPublisher = axisYViewModel.$scale.sink { newScale in
            self.axisYDelegate?.scaleDidChange(scale: newScale)
        }
        
        interactionYPublisher = axisYViewModel.$isEditing.removeDuplicates().sink { isEditing in
            if isEditing {
                self.axisYDelegate?.didBeginEditing()
            }
            else {
                self.axisYDelegate?.didEndEditing()
            }
        }
    }

    private func initAxisXViewModel() {
        if let axisXDataSource = axisXDataSource {
            axisXViewModel = PreciseAxis2DViewModel(
                defaultValue: axisXDataSource.defaultValue,
                defaultScale: axisXDataSource.defaultScale,
                minValue: axisXDataSource.minValue,
                maxValue: axisXDataSource.maxValue,
                minScale: axisXDataSource.minScale,
                maxScale: axisXDataSource.maxScale,
                numberOfUnits: axisXDataSource.numberOfUnits,
                isInfinite: axisXDataSource.isInfinite
            )
        }
        else {
            axisXViewModel = PreciseAxis2DViewModel()
        }
    }
    
    private func initAxisYViewModel() {
        if let axisYDataSource = axisYDataSource {
            axisYViewModel = PreciseAxis2DViewModel(
                defaultValue: axisYDataSource.defaultValue,
                defaultScale: axisYDataSource.defaultScale,
                minValue: axisYDataSource.minValue,
                maxValue: axisYDataSource.maxValue,
                minScale: axisYDataSource.minScale,
                maxScale: axisYDataSource.maxScale,
                numberOfUnits: axisYDataSource.numberOfUnits,
                isInfinite: axisYDataSource.isInfinite
            )
        }
        else {
            axisYViewModel = PreciseAxis2DViewModel()
        }
    }
    
    private func loadSlider() {
        sliderViewController?.removeFromParent()
        sliderViewController?.view.removeFromSuperview()
        
        initSlider()

        guard let sliderViewController = sliderViewController else {
            return
        }
        
        addChild(sliderViewController)
        sliderViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sliderViewController.view)
        sliderViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            sliderViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            sliderViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            sliderViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sliderViewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override public func viewDidLoad() {
        applyAxisXDelegate()
        applyAxisYDelegate()
        loadSlider()
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
