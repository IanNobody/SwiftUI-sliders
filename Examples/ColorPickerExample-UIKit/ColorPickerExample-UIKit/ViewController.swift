//
//  ViewController.swift
//  ColorPickerExample-UIKit
//
//  Created by Šimon Strýček on 03.04.2022.
//

import UIKit
import PreciseSlider2D

class ViewController: UIViewController {
    var modalDelegate: BlurModalDelegate!
    @IBOutlet var colorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pickColor(_ sender: Any) {
        let colorPicker = ColorPicker()
        colorPicker.completion = didPickColor
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        colorButton.tintColor.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        
        colorPicker.setDefaultValues(hue: hue * 360, saturation: saturation * 100)
        
        modalDelegate = BlurModalDelegate(from: self, to: colorPicker)
        colorPicker.modalPresentationStyle = .custom
        colorPicker.transitioningDelegate = modalDelegate
        present(colorPicker, animated: true)
    }
    
    func didPickColor(hue: Double, saturation: Double) {
        colorButton.tintColor = UIColor(hue: hue/360, saturation: saturation/100, brightness: 1, alpha: 1)
    }
}
