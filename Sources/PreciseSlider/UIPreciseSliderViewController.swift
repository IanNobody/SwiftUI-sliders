//
//  UIPreciseSliderViewController.swift
//  
//
//  Created by Šimon Strýček on 28.03.2022.
//

#if !os(macOS)

import UIKit
import SwiftUI
import Combine

open class UIPreciseSliderViewController: UIViewController {
    @ObservedObject private var viewModel: PreciseSliderViewModel = PreciseSliderViewModel()
    public var dataSource: PreciseSliderDataSource? {
        didSet {
            createViewModel()
            loadSlider()
        }
    }
    
    public var delegate: PreciseSliderDelegate?
    
    public var value: Double {
        get {
            viewModel.value
        }
        set {
            viewModel.move(toValue: newValue)
        }
    }
    
    public var scale: Double {
        get {
            viewModel.scale
        }
        set {
            viewModel.zoom(toValue: newValue)
        }
    }
    
    public var isEditingValue: Bool {
        viewModel.isEditing
    }
    
    private var valuePublisher: AnyCancellable?
    private var scalePublisher: AnyCancellable?
    private var interactionPublisher: AnyCancellable?
    private var sliderViewController: UIHostingController<PreciseSliderView<Text>>?
    
    private func initSlider() {
        sliderViewController = UIHostingController(
            rootView:
                PreciseSliderView(viewModel: viewModel) { value, step in
                    Text(self.dataSource?.unitLabelText(for: value, with: step) ?? "")
                        .foregroundColor(Color(self.dataSource?.unitLabelColor(for: value, with: step) ?? .white))
                        .font(Font((self.dataSource?.unitLabelFont(for: value, with: step) ?? UIFont.systemFont(ofSize: 6)) as CTFont))
                }
        )
    }
    
    private func createViewModel() {
        if let dataSource = dataSource {
            viewModel = PreciseSliderViewModel(
                defaultValue: dataSource.defaultValue,
                defaultScale: dataSource.defaultScale,
                minValue: dataSource.minValue,
                maxValue: dataSource.maxValue,
                minScale: dataSource.minScale,
                maxScale: dataSource.maxScale,
                numberOfUnits: dataSource.numberOfUnits,
                isInfinite: dataSource.isInfinite
            )
        }
        else {
            viewModel = PreciseSliderViewModel()
        }
    }
    
    private func applyDelegate() {
        valuePublisher = viewModel.valuePublisher.sink { newValue in
            self.delegate?.valueDidChange(value: newValue)
        }
        
        scalePublisher = viewModel.$scale.sink { newScale in
            self.delegate?.scaleDidChange(scale: newScale)
        }
        
        interactionPublisher = viewModel.$isEditing.removeDuplicates().sink { isEditing in
            if isEditing {
                self.delegate?.didBeginEditing()
            }
            else {
                self.delegate?.didEndEditing()
            }
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
        loadSlider()
        applyDelegate()
    }
}

#endif
