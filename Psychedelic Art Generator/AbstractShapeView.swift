//
//  AbstractShapeView.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/17/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit

class AbstractShapeView: UIView {
    var identifier: String = ""
    
    //Update shape dimensions
    func updateWidth(width: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.height)
    }
    
    func updateHeight(height: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: height)
    }
    
    func updateX(x: CGFloat) {
        self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
    }
    
    func updateY(y: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.width, height: self.frame.height)
    }
}
