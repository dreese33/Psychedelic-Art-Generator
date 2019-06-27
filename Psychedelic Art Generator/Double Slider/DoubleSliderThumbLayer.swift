//
//  DoubleSliderThumbLayer.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 6/19/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit
import QuartzCore

class DoubleSliderThumbLayer: CALayer {
    
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var doubleSlider: DoubleSlider?
    
    //Draw
    override func draw(in ctx: CGContext) {
        if let slider = doubleSlider {
            let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            // Fill - with a subtle shadow
            let shadowColor = UIColor.gray
            ctx.setFillColor(slider.thumbTintColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
            
            // Outline
            ctx.setStrokeColor(shadowColor.cgColor)
            ctx.setLineWidth(0.5)
            ctx.addPath(thumbPath.cgPath)
            ctx.strokePath()
            
            if highlighted {
                ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
                ctx.addPath(thumbPath.cgPath)
                ctx.fillPath()
            }
        }
    }
}
