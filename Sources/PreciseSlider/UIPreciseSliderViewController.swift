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
            updateSlider()
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
    public let preciseSliderView = UIPreciseSlider()
    
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
        
        applyDelegate()
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
    
    private func updateSlider() {
        createViewModel()
        preciseSliderView.updateView(with: viewModel, with: dataSource)
    }
    
    override public func loadView() {
        applyDelegate()
        preciseSliderView.updateView(with: viewModel, with: dataSource)
        view = preciseSliderView
    }
}

#endif
