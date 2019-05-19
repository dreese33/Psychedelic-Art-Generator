//
//  ShapeOptions.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/17/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit

class ShapeOptions: ArtCanvas {
    
    //Outlets and Actions
    
    //Text field outlets
    @IBOutlet weak var sizeX: UITextField!
    @IBOutlet weak var sizeY: UITextField!
    @IBOutlet weak var posX: UITextField!
    @IBOutlet weak var posY: UITextField!
    
    //Button actions
    /*
    @IBAction func cancel(_ sender: Any) {
        print("Cancelled")
        self.dismiss(animated: false, completion: nil)
    }*/
    @IBAction func moreOptions(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizeX.addTarget(self, action: #selector(sizeXChanged(_:)), for: .editingDidEnd)
        sizeY.addTarget(self, action: #selector(sizeYChanged(_:)), for: .editingDidEnd)
        posX.addTarget(self, action: #selector(posXChanged(_:)), for: .editingDidEnd)
        posY.addTarget(self, action: #selector(posYChanged(_:)), for: .editingDidEnd)
    }
    
    @objc func sizeXChanged(_ sender: Any) {
        super.imageView.addSubview(CircleView(frame: CGRect(x: 100, y: 100, width: 100, height: 100), identifier: "Circle4"))
        /*
        print("Started")
        for view in super.imageView.subviews {
            print("View")
            if let shapeView = view as? AbstractShapeView {
                if (shapeView.identifier == "Circle1") {
                    if let width = NumberFormatter().number(from: sizeX.text!) {
                        super.imageView.willRemoveSubview(shapeView)
                        super.imageView.addSubview(CircleView(frame: CGRect(x: shapeView.frame.maxX, y: shapeView.frame.maxY, width: CGFloat(truncating: width), height: shapeView.bounds.height), identifier: "Circle1"))
                    }
                }
            }
        }*/
    }
    
    @objc func sizeYChanged(_ sender: Any) {
        
    }
    
    @objc func posXChanged(_ sender: Any) {
        
    }
    
    @objc func posYChanged(_ sender: Any) {
        
    }
}
