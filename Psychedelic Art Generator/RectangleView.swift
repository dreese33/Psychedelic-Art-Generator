//
//  RectangleView.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/15/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit
import CoreGraphics

class RectangleView: AbstractShapeView {
    
    //var identifier: String = ""
    
    init(frame: CGRect, identifier: String) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        super.identifier = identifier
        self.draw(frame)
    }
    
    /*
     override init(frame: CGRect) {
     super.init(frame: frame)
     }
     
     */
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Get the Graphics Context
        if let context = UIGraphicsGetCurrentContext() {
            
            // Set the circle outerline-width
            context.setLineWidth(5.0)
            
            // Set the circle outerline-colour
            context.setStrokeColor(UIColor.red.cgColor)
            // UIColor.red.set()
            
            //Create Rectangle
            context.addRect(rect)
            context.strokePath()
        }
    }
}

