//
//  NewObjectConfigurationFromTable.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/14/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit

class NewObjectConfigurationFromTable: UINavigationController, UIPopoverPresentationControllerDelegate {
    
    //Which toolbar is activated
    public static var newToolbarActivated: Bool = false
    public static var toolSelected: IndexPath = IndexPath(row: 0, section: 0)
    
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
        let additionalShape = ArtCanvas.currentShape!.copy() as! AbstractShapeView
        print("Worked past cast")
        
        let addShapeXY = shapeView!.bounds.width / 6
        let heightWidthFactor = additionalShape.bounds.height / additionalShape.bounds.width
        
        if (heightWidthFactor == 0) {
            additionalShape.frame = CGRect(x: addShapeXY, y: addShapeXY, width: shapeView!.bounds.width * (2/3), height: shapeView!.bounds.height * (2/3))
        } else if (heightWidthFactor < 1) {
            let newWidth = shapeView!.bounds.width * (2/3)
            additionalShape.frame = CGRect(x: addShapeXY, y: addShapeXY, width: newWidth, height: newWidth * heightWidthFactor)
        } else {
            let newHeight = shapeView!.bounds.height * (2/3)
            additionalShape.frame = CGRect(x: addShapeXY, y: addShapeXY, width: newHeight * (1 / heightWidthFactor), height: newHeight)
        }
        
        additionalShape.center = CGPoint(x: shapeView!.bounds.width / 2, y: shapeView!.bounds.height / 2)
        
        shapeView?.addSubview(additionalShape)
        shapeView?.layer.borderWidth = 1
        self.view.addSubview(shapeView!)
    }
    
    //Popover presentation enabled
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
