//
//  CircleView.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/15/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit
import CoreGraphics

class CircleView: AbstractShapeView, NSCopying {

    init(frame: CGRect, identifier: String) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        super.identifier = identifier
        self.draw(frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        // Get the Graphics Context
        if let context = UIGraphicsGetCurrentContext() {
            
            // Set the circle outerline-width
            //context.setLineWidth(1.0)
            
            // Set the circle outerline-colour
            //context.setStrokeColor(UIColor.red.cgColor)
           // UIColor.red.set()
            
            // Create Circle
            //let center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
            //let radius = frame.size.width / 2
            //context.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
            //context.addEllipse(in: frame)
            
            if (self.colorNeedsUpdated) {
                
                let ellipsePath = UIBezierPath(ovalIn: self.bounds)
                self.color!.setFill()
                ellipsePath.fill()
                
                context.addPath(ellipsePath.cgPath)
                
                self.colorNeedsUpdated = false
                return
            }
            
            let ellipsePath = UIBezierPath(ovalIn: self.bounds)
            UIColor.red.setFill()
            ellipsePath.fill()
            self.color = UIColor.red
        
            //ellipsePath.stroke()
            //context.add
            //context.setFillColor(UIColor.red.cgColor)
            //context.fillPath()
        
            // Draw
            context.strokePath()
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CircleView(frame: self.frame, identifier: self.identifier)
        return copy
    }
    
    //Update shape color
    override func updateColor(color: UIColor) {
        self.color = color
        self.colorNeedsUpdated = true
        self.draw(self.frame)
        self.setNeedsDisplay()
    }
}
