//
//  DoubleSlider.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 6/19/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

//Alignment
enum Alignment {
    case vertical
    case horizontal
}

//Slightly modified code from RayWenderlich
class DoubleSlider: UIControl {
    
    //Position
    var alignment: Alignment?
    
    //Thumbs and tracking
    let lowerThumbLayer = DoubleSliderThumbLayer()
    let upperThumbLayer = DoubleSliderThumbLayer()
    let trackLayer = DoubleSliderTrackLayer()
    
    var previousLocation = CGPoint()
    
    //Make it pretty
    var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var thumbTintColor: UIColor = UIColor.white {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    var curvaceousness: CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    //Basic controls
    var minimumValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: Double = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var lowerValue: Double = 0.2 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var upperValue: Double = 0.8 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var thumbWidth: CGFloat {
        if (alignment == .vertical) {
            return CGFloat(bounds.width)
        }
        
        return CGFloat(bounds.height)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    convenience init(frame: CGRect, orientation: Alignment) {
        self.init(frame: frame)
        self.alignment = orientation
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.doubleSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.doubleSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.doubleSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
        
        if (alignment == nil) {
            alignment = .horizontal
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if (alignment == .horizontal) {
            trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        } else {
            trackLayer.frame = bounds.insetBy(dx: bounds.width / 3, dy: 0.0)
        }
        
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(value: lowerValue))
        
        if (alignment == .horizontal) {
            lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0,
                                           width: thumbWidth, height: thumbWidth)
        } else {
            lowerThumbLayer.frame = CGRect(x: 0.0, y: lowerThumbCenter - thumbWidth / 2.0, width: thumbWidth, height: thumbWidth)
        }
        
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(value: upperValue))
        
        if (alignment == .horizontal) {
            upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: 0.0,
                                       width: thumbWidth, height: thumbWidth)
        } else {
            upperThumbLayer.frame = CGRect(x: 0.0, y: upperThumbCenter - thumbWidth / 2.0, width: thumbWidth, height: thumbWidth)
        }
        
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func positionForValue(value: Double) -> Double {
        if (alignment == .vertical) {
            return Double(bounds.height - thumbWidth) * (value - minimumValue) / (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
        }
        
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    //Tracking functions
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        // Hit test the thumb layers
        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // 1. Determine by how much the user has dragged
        var deltaLocation = Double(location.x - previousLocation.x)
        if (alignment == .vertical) {
            deltaLocation = Double(location.y - previousLocation.y)
        }
        
        var deltaValue: Double!
        if (alignment == .horizontal) {
            deltaValue = ((maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth))
        } else {
            deltaValue = ((maximumValue - minimumValue) * deltaLocation / Double(bounds.height - thumbWidth))
        }
        
        previousLocation = location
        
        // 2. Update the values
        if lowerThumbLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
        } else if upperThumbLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
        }
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
}
