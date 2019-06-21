//
//  DoubleSliderTrackLayer.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 6/19/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit
import QuartzCore

class DoubleSliderTrackLayer: CALayer {
    weak var doubleSlider: DoubleSlider?
    
    //Draw
    override func draw(in ctx: CGContext) {
        if let slider = doubleSlider {
            // Clip
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            ctx.addPath(path.cgPath)
            
            // Fill the track
            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            // Fill the highlighted range
            ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
            let lowerValuePosition = CGFloat(slider.positionForValue(value: slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(value: slider.upperValue))
            
            
            var rect = CGRect()
            if (doubleSlider!.alignment == .horizontal) {
                rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
            } else {
                rect = CGRect(x: 0.0, y: lowerValuePosition, width: bounds.width, height: upperValuePosition - lowerValuePosition)
            }
            
            ctx.fill(rect)
        }
    }
}
