//
//  NewObjectConfigurationFromTable.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/14/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit

class NewObjectConfigurationFromTable: UINavigationController, UIPopoverPresentationControllerDelegate {
    
    //Image view
    @IBOutlet var imageView: UIImageView!
    
    //Which toolbar is activated
    public static var newToolbarActivated: Bool = false
    public static var toolSelected: IndexPath = IndexPath(row: 0, section: 0)
    
    //Additional shape for modification
    public static var additionalShape: AbstractShapeView?
    
    //Shape subview
    var shapeView: UIImageView?
    
    //Outlets and Actions
    @IBOutlet weak var shapeToolbar: UIBarButtonItem!
    @IBAction func moreOptionsToolbar(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "toolbar")
        
        //Popover presentation style
        viewController.modalPresentationStyle = .popover
        
        //Specify anchor point
        viewController.popoverPresentationController?.barButtonItem = shapeToolbar
        viewController.preferredContentSize = CGSize(width: 74, height: UIScreen.main.bounds.height - 88)
        viewController.popoverPresentationController?.delegate = self
        
        //Present popover
        self.present(viewController, animated: false)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NewObjectConfigurationFromTable.newToolbarActivated = false
        ColorView.arrowAdded = false
        ColorView.initialPositionSet = false
        
        //print("Dismissed")
        ColorSaturationAndBrightnessSelector.selectionCircleAdded = false
        ColorView.currentArrowPositionAngle = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NewObjectConfigurationFromTable.newToolbarActivated = true
        self.view.backgroundColor = UIColor.white
        
        //Add shape view to right corner
        let shapeWidth = self.view.bounds.width / 4
        let xPos = self.view.bounds.width - shapeWidth
        let yPos = self.view.bounds.height - shapeWidth
        shapeView = UIImageView(frame: CGRect(x: xPos, y: yPos, width: shapeWidth, height: shapeWidth))
        
        //Issue with the copy method
        print("Worked")
        if (NewObjectConfigurationFromTable.additionalShape == nil) {
            NewObjectConfigurationFromTable.additionalShape = ArtCanvas.currentShape!.copy() as! AbstractShapeView
        }
        print("Worked past cast")
        
        let addShapeXY = shapeView!.bounds.width / 6
        let heightWidthFactor = NewObjectConfigurationFromTable.additionalShape!.bounds.height / NewObjectConfigurationFromTable.additionalShape!.bounds.width
        
        if (heightWidthFactor == 0) {
            NewObjectConfigurationFromTable.additionalShape!.frame = CGRect(x: addShapeXY, y: addShapeXY, width: shapeView!.bounds.width * (2/3), height: shapeView!.bounds.height * (2/3))
        } else if (heightWidthFactor < 1) {
            let newWidth = shapeView!.bounds.width * (2/3)
            NewObjectConfigurationFromTable.additionalShape!.frame = CGRect(x: addShapeXY, y: addShapeXY, width: newWidth, height: newWidth * heightWidthFactor)
        } else {
            let newHeight = shapeView!.bounds.height * (2/3)
            NewObjectConfigurationFromTable.additionalShape!.frame = CGRect(x: addShapeXY, y: addShapeXY, width: newHeight * (1 / heightWidthFactor), height: newHeight)
        }
        
        NewObjectConfigurationFromTable.additionalShape!.center = CGPoint(x: shapeView!.bounds.width / 2, y: shapeView!.bounds.height / 2)
        
        shapeView?.addSubview(NewObjectConfigurationFromTable.additionalShape!)
        shapeView?.layer.borderWidth = 1
        self.view.addSubview(shapeView!)
        
        //Add color wheel to view
        self.view.addSubview(createColorWheel())
    }
    
    //Popover presentation enabled
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Creates the hollow circle color wheel
    func createColorWheel() -> UIView {
        let colorWheelDimension = UIScreen.main.bounds.width * (4/5)
        let view = ColorView(frame: CGRect(x: 0, y: 0, width: colorWheelDimension, height: colorWheelDimension))
        view.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.5)
        
        return view
    }
}
