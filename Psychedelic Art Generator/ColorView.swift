//
//  ColorView.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/22/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit
import CoreGraphics

class ColorView: UIView {
    
    //First time drawn
    //private static var firstTimeDrawn: Bool = true
    
    //Arrow origin
    private var arrowCenterOrigin: CGPoint?
    private var circleCenterPoint: CGPoint?
    
    //Arrow added
    public static var arrowAdded: Bool = false
    private static var arrowWidth: CGFloat?
    
    //Current arrow position in radians
    public static var currentArrowPositionAngle: CGFloat = 0
    
    //Bezier paths
    public static var ellipsePath: UIBezierPath?
    public static var ellipsePathInner: UIBezierPath?
    private var innerSquare: ColorSaturationAndBrightnessSelector?
    
    //Ellipse path radius (outer)
    private var ellipsePathRadius: CGFloat?
    
    //Image view
    private var imageView: UIImageView?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Contains an empty initializer for this class
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        self.draw(frame)
    }
    
    //Draws the color view at the appropriate bounds
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            
            //Region between outer and inner circles contains the RGB colors
            //Outer circle
            ColorView.ellipsePath = UIBezierPath(ovalIn: CGRect(x: self.bounds.origin.x + 1, y: self.bounds.origin.y + 1, width: self.bounds.width - 2, height: self.bounds.height - 2))
            ColorView.ellipsePath!.lineWidth = 1
            context.addPath(ColorView.ellipsePath!.cgPath)
        
            //Assign circle center point and radius
            circleCenterPoint = CGPoint(x: self.bounds.origin.x + 1 + (ColorView.ellipsePath!.bounds.width / 2), y: self.bounds.origin.y + 1 + (ColorView.ellipsePath!.bounds.height / 2))
            ellipsePathRadius = (ColorView.ellipsePath!.bounds.width / 2) + 1

            //Inner circle
            let width = self.bounds.width

            ColorView.ellipsePathInner = UIBezierPath(ovalIn: CGRect(x: self.bounds.origin.x + (width / 10) + 2, y: self.bounds.origin.y + (width / 10) + 2, width: self.bounds.width - (width / 5) - 4, height: self.bounds.height - (width / 5) - 4))
            ColorView.ellipsePathInner!.lineWidth = 1
            context.addPath(ColorView.ellipsePathInner!.cgPath)

            //Adds pixels to the context
            if (!ColorView.arrowAdded) {
                ColorView.arrowAdded = true
                addArrowFunctionality(outerPath: ColorView.ellipsePath!)
            }

            addWheelHue(context)
            
            //Inner square
            innerSquare = ColorSaturationAndBrightnessSelector(frame: CGRect(x: ColorView.ellipsePathInner!.bounds.origin.x + (ColorView.ellipsePathInner!.bounds.width / 4), y: ColorView.ellipsePathInner!.bounds.origin.y + (ColorView.ellipsePathInner!.bounds.width / 4), width: ColorView.ellipsePathInner!.bounds.width / 2, height: ColorView.ellipsePathInner!.bounds.width / 2))
            self.addSubview(innerSquare!)
        }
    }
    
    //Function to add all of the lines to the color wheel
    func addWheelHue(_ context: CGContext) {

        //Inner and outer ellipse radii
        let innerRadius = ColorView.ellipsePathInner!.bounds.height / 2
        let outerRadius = ColorView.ellipsePath!.bounds.height / 2

        //Add lines
        for i in 0...3600 {
            //Line position
            var floatValue = ColorView.toRadians(degreeValue: (CGFloat(i) / 10))
            floatValue -= (1/2) * .pi
            
            let startPoint = CGPoint(x: innerRadius * cos(floatValue) + self.circleCenterPoint!.x, y: innerRadius * sin(floatValue) + self.circleCenterPoint!.y)
            let endPoint = CGPoint(x: outerRadius * cos(floatValue) + self.circleCenterPoint!.x, y: outerRadius * sin(floatValue) + self.circleCenterPoint!.y)

            //Line Color
            let hue = CGFloat(i) / 3600
            let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
            context.setStrokeColor(color.cgColor)
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            context.strokePath()
        }
    }

    //Function to add arrow functionality to context
    func addArrowFunctionality(outerPath: UIBezierPath) {
        let arrowImage = UIImage(named: "ColorWheelArrow")
        imageView = UIImageView(image: arrowImage)
        
        ColorView.arrowWidth = outerPath.bounds.width / 8
        arrowCenterOrigin = CGPoint(x: outerPath.bounds.origin.x + (outerPath.bounds.width / 2), y: outerPath.bounds.origin.y - (ColorView.arrowWidth! / 2))
        
        imageView!.bounds = CGRect(x: 0, y: 0, width: ColorView.arrowWidth!, height: ColorView.arrowWidth!)
        imageView!.center = arrowCenterOrigin!
        imageView!.tag = 1
        
        self.addSubview(imageView!)
    }
    
    //Touch functions to animate along the UIBezierPath
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.location(in: self) {
            if (ColorView.ellipsePath!.contains(touch) && !ColorView.ellipsePathInner!.contains(touch)) {
                self.rotateArrow(touch: touch)
                innerSquare!.draw(innerSquare!.frame)
                innerSquare!.setNeedsDisplay()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.location(in: self) {
            if (ColorView.ellipsePath!.contains(touch) && !ColorView.ellipsePathInner!.contains(touch)) {
                self.rotateArrow(touch: touch)
                innerSquare!.draw(innerSquare!.frame)
                innerSquare!.setNeedsDisplay()
            }
        }
    }
    
    //Arrow rotation functionality
    func rotateArrow(touch: CGPoint) {
        let distanceToCenter = sqrt(pow(touch.x - self.circleCenterPoint!.x, 2) + pow(touch.y - self.circleCenterPoint!.y, 2))
        let endDistance = self.ellipsePathRadius! - distanceToCenter
        let centerLineSlope = (touch.y - self.circleCenterPoint!.y) / (touch.x - self.circleCenterPoint!.x)
        
        let xVal = sqrt(pow(endDistance, 2) / (1 + pow(centerLineSlope, 2)))
        let yVal = centerLineSlope * xVal
        
        //Detects undefined slope error
        if (xVal == 0) {
            return
        }
        
        var rotationAngle = atan(yVal / xVal)
        
        let arrowMoveFactor = ColorView.arrowWidth! / 2
        
        var finalY: CGFloat
        var finalX: CGFloat
        
        if (touch.x > self.circleCenterPoint!.x) {
            rotationAngle += (1/2) * .pi
            finalY = touch.y + yVal - (arrowMoveFactor * cos(rotationAngle))
            
            finalX = touch.x + xVal + (arrowMoveFactor * sin(rotationAngle))
            self.imageView!.center = CGPoint(x: finalX, y: finalY)
            self.imageView!.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
        else {
            rotationAngle -= (1/2) * .pi
            finalY = touch.y - yVal - (arrowMoveFactor * cos(rotationAngle))
            
            finalX = touch.x - xVal + (arrowMoveFactor * sin(rotationAngle))
            self.imageView!.center = CGPoint(x: finalX, y: finalY)
            self.imageView!.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
        
        ColorView.currentArrowPositionAngle = rotationAngle
    }
    
    //Degrees and radians conversions
    public static func toDegrees(radianValue: CGFloat) -> CGFloat {
        var degreeValue = (radianValue * 180) / .pi
        while (degreeValue < 0) {
            degreeValue = degreeValue + 360
        }
        
        return degreeValue
    }
    
    public static func toRadians(degreeValue: CGFloat) -> CGFloat {
        var radianValue = (degreeValue * .pi) / 180
        while (radianValue < 0) {
            radianValue = radianValue + 360
        }
        
        return radianValue
    }
}



//Class for inner square
class ColorSaturationAndBrightnessSelector: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Draw/update brightness and saturation
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(1)
            context.setStrokeColor(UIColor.black.cgColor)
            context.strokePath()
            
            addWheelBrightnessAndSaturation(context: context)
        }
    }
    
    //Function to add all brightness and saturation values to the inner square
    func addWheelBrightnessAndSaturation(context: CGContext) {

        let arrowPositionDegrees = ColorView.toDegrees(radianValue: ColorView.currentArrowPositionAngle) * 10
        let hue = arrowPositionDegrees / 3600
        let innerSquareDivisionFactor = CGFloat(self.frame.width) / CGFloat(100)

        for i in 0...99 {
            for j in 0...99 {
                let color = UIColor(hue: hue, saturation: CGFloat(i) / 100, brightness: CGFloat(j) / 100, alpha: 1)
                context.setStrokeColor(color.cgColor)
                context.setFillColor(color.cgColor)

                let rect = CGRect(x: CGFloat(i) * innerSquareDivisionFactor, y: CGFloat(j) * innerSquareDivisionFactor, width: innerSquareDivisionFactor, height: innerSquareDivisionFactor)
                UIRectFill(rect)

                context.addRect(rect)
                context.strokePath()
            }
        }
    }
}
