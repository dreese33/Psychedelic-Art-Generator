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
    
    //Arrow origin
    private var arrowCenterOrigin: CGPoint?
    private var circleCenterPoint: CGPoint?
    
    //Arrow added
    public static var arrowAdded: Bool = false
    private static var arrowWidth: CGFloat?
    
    //Current arrow position in radians
    //Reset this to 0 when view is dismissed
    public static var currentArrowPositionAngle: CGFloat = 0
    
    //Bezier paths
    public static var ellipsePath: UIBezierPath?
    public static var ellipsePathInner: UIBezierPath?
    private var innerSquare: ColorSaturationAndBrightnessSelector?
    
    //Ellipse path radius (outer)
    private var ellipsePathRadius: CGFloat?
    
    //Initial position set
    public static var initialPositionSet: Bool = false
    
    //Image view
    private var imageView: UIImageView?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Contains an empty initializer for this class
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
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
            
            if (!ColorView.initialPositionSet) {
                ColorView.initialPositionSet = true
                print("Called")
                self.setColorPosition()
            }
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
            print(self.frame)
            if (ColorView.ellipsePath!.contains(touch) && !ColorView.ellipsePathInner!.contains(touch)) {
           // if (self.frame.contains(touch) && !ColorView.ellipsePathInner!.contains(touch)) {
                self.rotateArrow(touch: touch)
                innerSquare!.draw(innerSquare!.frame)
                innerSquare!.setNeedsDisplay()
                
                let color = ColorSaturationAndBrightnessSelector.getSelectedColor()
                ArtCanvas.currentShape!.updateColor(color: color)
                NewObjectConfigurationFromTable.additionalShape!.updateColor(color: color)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.location(in: self) {
            if (ColorView.ellipsePath!.contains(touch) && !ColorView.ellipsePathInner!.contains(touch)) {
            //if (self.frame.contains(touch) && !ColorView.ellipsePathInner!.contains(touch)) {
                self.rotateArrow(touch: touch)
                innerSquare!.draw(innerSquare!.frame)
                innerSquare!.setNeedsDisplay()
                
                let color = ColorSaturationAndBrightnessSelector.getSelectedColor()
                ArtCanvas.currentShape!.updateColor(color: color)
                NewObjectConfigurationFromTable.additionalShape!.updateColor(color: color)
            }
        }
    }
    
    //Arrow rotation functionality
    func rotateArrow(touch: CGPoint) {
        let distanceToCenter = sqrt(pow(touch.x - self.circleCenterPoint!.x, 2) + pow(touch.y - self.circleCenterPoint!.y, 2))
        print(distanceToCenter)
        
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
    
    //Arrow rotation based on degrees
    func rotateArrow(degrees: CGFloat) {
        var angleRadians = ColorView.toRadians(degreeValue: degrees)
        angleRadians -= (1/2) * .pi
        
        let outerRadius = ColorView.ellipsePath!.bounds.height / 2
        let rotationPoint = CGPoint(x: outerRadius * cos(angleRadians) + self.circleCenterPoint!.x, y: outerRadius * sin(angleRadians) + self.circleCenterPoint!.y)
        
        let arrowMoveFactor = ColorView.arrowWidth! / 2
        
        var finalY: CGFloat
        var finalX: CGFloat
        
        angleRadians += (1/2) * .pi
        finalY = rotationPoint.y - (arrowMoveFactor * cos(angleRadians))
        finalX = rotationPoint.x + (arrowMoveFactor * sin(angleRadians))
        
        self.imageView!.center = CGPoint(x: finalX, y: finalY)
        self.imageView!.transform = CGAffineTransform(rotationAngle: angleRadians)
        
        ColorView.currentArrowPositionAngle = angleRadians
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
    
    //Function to set color wheel to appropriate position upon loading
    func setColorPosition() {
        
        //Set hue position
        let color = ArtCanvas.currentShape!.color!
        
        //Gets hsb values
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        
        //Rotate arrow to proper position
        self.rotateArrow(degrees: hue * 360)
        
        //Set brightness and saturation position
        innerSquare!.setColorPosition(saturation: saturation, brightness: brightness)
    }
}



//Class for inner square
class ColorSaturationAndBrightnessSelector: UIView {
    
    //Selection circle added
    //Reset this to false when view is closed
    public static var selectionCircleAdded: Bool = false
    
    //Inner square selection circle
    private static var selectionCircle: UIView?
    //public static var selectedColor: UIColor?
    
    //View bounds for outside use
    public static var viewBounds: CGRect?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        
        if (!ColorSaturationAndBrightnessSelector.selectionCircleAdded) {
            ColorSaturationAndBrightnessSelector.selectionCircleAdded = true
            
            ColorSaturationAndBrightnessSelector.selectionCircle = UIView(frame: CGRect(x: self.bounds.width / 2, y: self.bounds.height / 2, width: self.bounds.width / 13, height: self.bounds.width / 13))
            
            let selectionCircleLayer = CAShapeLayer()
            selectionCircleLayer.fillColor = UIColor.clear.cgColor
            selectionCircleLayer.strokeColor = UIColor.black.cgColor
            selectionCircleLayer.path = UIBezierPath(arcCenter: CGPoint(x: ColorSaturationAndBrightnessSelector.selectionCircle!.bounds.width / 2, y: ColorSaturationAndBrightnessSelector.selectionCircle!.bounds.height / 2), radius: self.bounds.width / 26, startAngle: 0, endAngle: 360, clockwise: true).cgPath
            ColorSaturationAndBrightnessSelector.selectionCircle!.layer.addSublayer(selectionCircleLayer)
            
            self.addSubview(ColorSaturationAndBrightnessSelector.selectionCircle!)

            ColorSaturationAndBrightnessSelector.viewBounds = self.bounds
        }
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
    
    //Touch handling inside of saturation and brightness selector
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.location(in: self) {
            UIView.animate(withDuration: 0.25, animations: { ()
                ColorSaturationAndBrightnessSelector.selectionCircle!.center = CGPoint(x: touch.x, y: touch.y)
                
                let color = ColorSaturationAndBrightnessSelector.getSelectedColor()
                ArtCanvas.currentShape!.updateColor(color: color)
                NewObjectConfigurationFromTable.additionalShape!.updateColor(color: color)
            })
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.location(in: self) {
            UIView.animate(withDuration: 0.25, animations: { ()
                ColorSaturationAndBrightnessSelector.selectionCircle!.center = CGPoint(x: touch.x, y: touch.y)
                
                let color = ColorSaturationAndBrightnessSelector.getSelectedColor()
                ArtCanvas.currentShape!.updateColor(color: color)
                NewObjectConfigurationFromTable.additionalShape!.updateColor(color: color)
            })
        }
    }
    
    //Selected color
    public static func getSelectedColor() -> UIColor {
        let selectionCenterPoint = ColorSaturationAndBrightnessSelector.selectionCircle!.center
        let relativeCenterPoint = CGPoint(x: selectionCenterPoint.x / ColorSaturationAndBrightnessSelector.viewBounds!.width , y: selectionCenterPoint.y / ColorSaturationAndBrightnessSelector.viewBounds!.height)
        
        //Calculate hue
        let arrowPositionDegrees = ColorView.toDegrees(radianValue: ColorView.currentArrowPositionAngle) * 10
        let hue = arrowPositionDegrees / 3600
        
        let color = UIColor(hue: hue, saturation: relativeCenterPoint.x, brightness: relativeCenterPoint.y, alpha: 1)
        return color
    }
    
    //Sets color position upon load
    func setColorPosition(saturation: CGFloat, brightness: CGFloat) {
        ColorSaturationAndBrightnessSelector.selectionCircle!.center = CGPoint(x: saturation * self.bounds.width, y: brightness * self.bounds.height)
    }
}
