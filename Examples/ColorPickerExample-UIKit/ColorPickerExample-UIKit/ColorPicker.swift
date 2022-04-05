//
//  ColorPicker.swift
//  ColorPickerExample-UIKit
//
//  Created by Šimon Strýček on 04.04.2022.
//

import UIKit
import PreciseSlider2D

class ColorPicker: UIViewController, PreciseSlider2DDataSource {
    private var defaultHue: Double = 0
    private var defaultSaturation: Double = 0
    private let slider = UIPreciseSlider2DViewController()
    private var doneButton: UIButton!
    public var completion: ((_ hue: Double, _ saturation: Double) -> ())?
    
    var contentImage: UIImage?
    
    func setDefaultValues(hue: Double, saturation: Double) {
        defaultHue = hue
        defaultSaturation = saturation
    }
    
    var hue: Double {
        slider.axisXValue
    }
    
    var saturation: Double {
        slider.axisYValue
    }
    
    func contentImage(ofSize: CGSize, withScale: CGSize) -> UIImage? {
        if contentImage == nil || contentImage?.size != ofSize
        {
            let colorLayer = CAGradientLayer()
            colorLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: ofSize)
            colorLayer.colors = [
                    UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 1).cgColor,
                    UIColor(hue: 60/360, saturation: 1, brightness: 1, alpha: 1).cgColor,
                    UIColor(hue: 120/360, saturation: 1, brightness: 1, alpha: 1).cgColor,
                    UIColor(hue: 180/360, saturation: 1, brightness: 1, alpha: 1).cgColor,
                    UIColor(hue: 240/360, saturation: 1, brightness: 1, alpha: 1).cgColor,
                    UIColor(hue: 300/360, saturation: 1, brightness: 1, alpha: 1).cgColor,
                    UIColor(hue: 1, saturation: 1, brightness: 1, alpha: 1).cgColor
            ]
            colorLayer.startPoint = CGPoint(x: 0, y: 0)
            colorLayer.endPoint = CGPoint(x: 1, y: 0)
            
            let saturationLayer = CAGradientLayer()
            saturationLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: ofSize)
            saturationLayer.colors = [
                UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0).cgColor,
                UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1).cgColor
            ]
            saturationLayer.startPoint = CGPoint(x: 0, y: 1)
            saturationLayer.endPoint = CGPoint(x: 0, y: 0)
            
            UIGraphicsBeginImageContext(ofSize)
            colorLayer.render(in: UIGraphicsGetCurrentContext()!)
            saturationLayer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            contentImage = image
        }
        
        return contentImage
    }
    
    func initBackground() {
        view = UIView()
        view.backgroundColor = .clear
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(cancelPicking))
        )
    }
    
    func initSlider() {
        slider.dataSource = self
        slider.axisXDataSource = AxisDataSource(with: defaultHue, maxValue: 360)
        slider.axisYDataSource = AxisDataSource(with: defaultSaturation, maxValue: 100)
        slider.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slider.view)
    }
    
    func initDoneButton() {
        let doneButton = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Hotovo"
        configuration.titlePadding = 10
        doneButton.configuration = configuration
        doneButton.addTarget(self, action: #selector(donePicking), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        self.doneButton = doneButton
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            slider.view.heightAnchor.constraint(equalToConstant: 350),
            slider.view.widthAnchor.constraint(equalToConstant: 350),
            slider.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slider.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            //
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.topAnchor.constraint(equalTo: slider.view.layoutMarginsGuide.bottomAnchor, constant: 30)
        ])
    }
    
    override func loadView() {
        initBackground()
        initSlider()
        initDoneButton()
        setupLayout()
    }
    
    @objc private func donePicking() {
        completion?(hue, saturation)
        dismiss(animated: true)
    }
    
    @objc private func cancelPicking() {
        dismiss(animated: true)
    }
}

class AxisDataSource: PreciseAxis2DDataSource {
    public var maxValue: Double
    public var minScale: Double = 0.5
    public var maxScale: Double = 10
    public var numberOfUnits: Int = 10
    public var defaultValue: Double
    
    init(with defaultValue: Double, maxValue: Double) {
        self.defaultValue = defaultValue
        self.maxValue = maxValue
    }
    
    public func unitLabelText(for value: Double, with stepSize: Double) -> String {
        String(round(value * 100) / 100)
    }
    
    public func unitLabelFont(for value: Double, with stepSize: Double) -> UIFont {
        UIFont.systemFont(ofSize: 7)
    }
}
