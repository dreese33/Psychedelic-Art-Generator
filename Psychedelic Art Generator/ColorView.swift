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
    
    //Bezier paths
    private var ellipsePath: UIBezierPath?
    private var ellipsePathInner: UIBezierPath?
    
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
            ellipsePath = UIBezierPath(ovalIn: CGRect(x: self.bounds.origin.x + 1, y: self.bounds.origin.y + 1, width: self.bounds.width - 2, height: self.bounds.height - 2))
            ellipsePath!.lineWidth = 1
            context.addPath(ellipsePath!.cgPath)
            
            //Assign circle center point and radius
            circleCenterPoint = CGPoint(x: self.bounds.origin.x + 1 + (ellipsePath!.bounds.width / 2), y: self.bounds.origin.y + 1 + (ellipsePath!.bounds.height / 2))
            ellipsePathRadius = (ellipsePath!.bounds.width / 2) + 1
            
            //Inner circle
            let width = self.bounds.width
            
            ellipsePathInner = UIBezierPath(ovalIn: CGRect(x: self.bounds.origin.x + (width / 10) + 2, y: self.bounds.origin.y + (width / 10) + 2, width: self.bounds.width - (width / 5) - 4, height: self.bounds.height - (width / 5) - 4))
            ellipsePathInner!.lineWidth = 1
            context.addPath(ellipsePathInner!.cgPath)
            
            //Inner square
            let innerRect = CGRect(x: ellipsePathInner!.bounds.origin.x + (ellipsePathInner!.bounds.width / 4), y: ellipsePathInner!.bounds.origin.y + (ellipsePathInner!.bounds.width / 4), width: ellipsePathInner!.bounds.width / 2, height: ellipsePathInner!.bounds.width / 2)
            context.setLineWidth(1)
            //context.setFillColor(UIColor.clear)
            context.addRect(innerRect)
            
            //Adds pixels to the context
            if (!ColorView.arrowAdded) {
                ColorView.arrowAdded = true
                addArrowFunctionality(outerPath: ellipsePath!)
            }
            
            context.strokePath()
        }
    }
    
    //Function to add all of the pixels to the color wheel
    func addPixels(_ context: CGContext) {
        
    }
    
    //Function to add arrow functionality to context
    func addArrowFunctionality(outerPath: UIBezierPath) {
        let arrowImage = UIImage(named: "ColorWheelArrow")
        imageView = UIImageView(image: arrowImage)
        
        let arrowWidth = outerPath.bounds.width / 8
        arrowCenterOrigin = CGPoint(x: outerPath.bounds.origin.x + (outerPath.bounds.width / 2), y: outerPath.bounds.origin.y - (arrowWidth / 2) - 5)
        
        imageView!.bounds = CGRect(x: 0, y: 0, width: arrowWidth, height: arrowWidth)
        imageView!.center = arrowCenterOrigin!
        imageView!.tag = 1
        
        self.addSubview(imageView!)
    }
    
    //Touch functions to animate along the UIBezierPath
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.location(in: self) {
            if (ellipsePath!.contains(touch) && !ellipsePathInner!.contains(touch)) {
                
                //Movement of arrow
                //UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    
                //Make image rotate around the outer circle
                //Y touch value with proper coordinates
                
                //Deal with NaN coordinates, which are the endpoints of the circle
                
                let distanceToCenter = sqrt(pow(touch.x - self.circleCenterPoint!.x, 2) + pow(touch.y - self.circleCenterPoint!.y, 2))
                let endDistance = self.ellipsePathRadius! - distanceToCenter
                let centerLineSlope = (touch.y - self.circleCenterPoint!.y) / (touch.x - self.circleCenterPoint!.x)
                
                let xVal = sqrt(pow(endDistance, 2) / (1 + pow(centerLineSlope, 2)))
                let yVal = centerLineSlope * xVal
                
                if (touch.x > self.circleCenterPoint!.x) {
                    let finalY = touch.y + yVal
                    let finalX = touch.x + xVal
                    self.imageView!.center = CGPoint(x: finalX, y: finalY)
                    let rotationAngle = atan(yVal / xVal) + (1/2) * .pi
                    self.imageView!.transform = CGAffineTransform(rotationAngle: rotationAngle)
                }
                else {
                    let finalY = touch.y - yVal
                    let finalX = touch.x - xVal
                    self.imageView!.center = CGPoint(x: finalX, y: finalY)
                    let rotationAngle = atan(yVal / xVal) - (1/2) * .pi
                    self.imageView!.transform = CGAffineTransform(rotationAngle: rotationAngle)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.location(in: self) {
            if (ellipsePath!.contains(touch) && !ellipsePathInner!.contains(touch)) {
                self.imageView!.center = touch
            }
        }
    }
    
    //Arrow rotation functionality
    func addArrowRotationFunctionality() {
        
    }
}
