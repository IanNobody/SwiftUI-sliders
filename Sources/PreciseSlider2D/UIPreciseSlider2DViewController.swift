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
            createAxisXViewModel()
            updateSlider()
        }
    }

    public var axisYDataSource: PreciseAxis2DDataSource? {
        didSet {
            createAxisYViewModel()
            updateSlider()
        }
    }

    public var dataSource: PreciseSlider2DDataSource? {
        didSet {
            updateSlider()
        }
    }

    public weak var axisXDelegate: PreciseAxis2DDelegate?
    public weak var axisYDelegate: PreciseAxis2DDelegate?

    public var axisXValue: Double {
        get {
            axisXViewModel.value
        }
        set {
            axisXViewModel.move(toValue: newValue)
        }
    }

    public var axisXScale: Double {
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

    public var axisYScale: Double {
        get {
            axisYViewModel.scale
        }
        set {
            axisYViewModel.zoom(toValue: newValue)
        }
    }

    public var isEditingValue: Bool {
        axisXViewModel.isEditing || axisYViewModel.isEditing
    }

    private var valueXPublisher: AnyCancellable?
    private var scaleXPublisher: AnyCancellable?
    private var interactionXPublisher: AnyCancellable?

    private var valueYPublisher: AnyCancellable?
    private var scaleYPublisher: AnyCancellable?
    private var interactionYPublisher: AnyCancellable?

    public var preciseSlider2DView = UIPreciseSlider2D()

    private func applyAxisXDelegate() {
        valueXPublisher = axisXViewModel.valuePublisher.sink { newValue in
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
        valueYPublisher = axisYViewModel.valuePublisher.sink { newValue in
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

    private func createAxisXViewModel() {
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

    private func createAxisYViewModel() {
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

    private func updateSlider() {
        preciseSlider2DView.updateView(
            axisXViewModel: axisXViewModel,
            axisYViewModel: axisYViewModel,
            axisXDataSource: axisXDataSource,
            axisYDataSource: axisYDataSource,
            dataSource: dataSource
        )
    }

    override public func loadView() {
        applyAxisXDelegate()
        applyAxisYDelegate()
        updateSlider()
        view = preciseSlider2DView
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
