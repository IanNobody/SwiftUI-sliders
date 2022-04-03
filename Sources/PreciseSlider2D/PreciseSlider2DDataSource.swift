//
//  PreciseSlider2DDataSource.swift
//  
//
//  Created by Šimon Strýček on 01.04.2022.
//

#if !os(macOS)

import UIKit

public protocol PreciseSlider2DDataSource {
    func contentImage(ofSize: CGSize, withScale: CGSize) -> UIImage?
}

#endif
