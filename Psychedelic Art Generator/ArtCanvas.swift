//
//  ArtCanvas.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/14/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit
import CoreGraphics

//This is the most important class in the program
//This is where all shapes, tesselations, and fractals will be drawn and configured
class ArtCanvas: UIViewController, UIPopoverPresentationControllerDelegate {
    
    //Tool selected, modified in Toolbar class
    public static var toolSelected: IndexPath = IndexPath(row: 0, section: 0)
    
    //User touch on screen
    var touchEnabled: Bool = true
    
    //Current shape being modified
    var currentShape: AbstractShapeView?
    
    //Stamp tool enabled
    var showAdditionalOptions: Bool = true
    
    //The art canvas
    @IBOutlet weak var imageView: UIImageView!
    
    //Toolbar display action and outlet
    @IBOutlet weak var toolbar: UIBarButtonItem!
    @IBAction func toolbarAction(_ sender: Any) {
        displayViewController(identifier: "toolbar")
    }
    
    //Popover presentation enabled
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Default override
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NewObjectConfigurationFromTable.newToolbarActivated = false
    }
    
    //Code runs when tool selection is closed
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touchEnabled) {
            
            //Ensures touch is inside of image view
            if let touch = touches.first?.location(in: imageView) {
                
                //Tool options
                switch ArtCanvas.toolSelected.row {
                case 0:
                    print("Circle")
                    
                    //Adds default circle to art canvas
                    let randomRectVal = CGRect(x: touch.x - 50, y: touch.y - 50, width: 100, height: 100)
                    let rectView = CircleView(frame: randomRectVal, identifier: "Circle1")
                    currentShape = rectView
                    imageView.addSubview(rectView)
                    
                    if (showAdditionalOptions) {
                        
                        //Adds shape options view
                        addShapeOptions(rectView: rectView)
                    }
                case 1:
                    print("Rectangle")
                    let randomRectVal = CGRect(x: touch.x - 50, y: touch.y - 50, width: 100, height: 100)
                    let rectView = RectangleView(frame: randomRectVal, identifier: "Rectangle1")
                    currentShape = rectView
                    imageView.addSubview(rectView)
                    
                    if (showAdditionalOptions) {
                        
                        //Adds shape options view
                        addShapeOptions(rectView: rectView)
                    }
                case 2:
                    print("Pentagon")
                case 3:
                    print("Star")
                default:
                    print("Something went wrong")
                }
            }
        }
    }
    
    
    //Cancel action, removes added shape
    @IBAction func cancel(_ sender: Any) {
        //Remove current shape
        currentShape?.removeFromSuperview()
        currentShape = nil
        
        //Remove toolbar
        self.view.viewWithTag(1)?.removeFromSuperview()
        touchEnabled = true
    }
    
    //Done action, completes adding shape
    @IBAction func done(_ sender: Any) {
        //Remove toolbar
        self.view.viewWithTag(1)?.removeFromSuperview()
        touchEnabled = true
    }
    
    //More options for shape
    @IBAction func moreOptions(_ sender: Any) {
        displayViewController(identifier: "newObjectConfiguration")
    }
    
    //Shape resizing actions
    @IBAction func widthChanged(_ sender: Any) {
        textFieldChanged(field: 1)
    }
    
    @IBAction func heightChanged(_ sender: Any) {
        textFieldChanged(field: 2)
    }
    
    @IBAction func xChanged(_ sender: Any) {
        textFieldChanged(field: 3)
    }
    
    @IBAction func yChanged(_ sender: Any) {
        textFieldChanged(field: 4)
    }
    
    
    //Functions for program
    
    /*
        Displays the toolbar view controller when the toolbar button is pressed
     */
    func displayViewController(identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        
        //Popover presentation style
        viewController.modalPresentationStyle = .popover
        
        //Specify anchor point
        
        if (identifier == "toolbar") {
            viewController.popoverPresentationController?.barButtonItem = toolbar
            viewController.preferredContentSize = CGSize(width: 74, height: UIScreen.main.bounds.height - 88)
            viewController.popoverPresentationController?.delegate = self
        }
        
        //Present popover
        self.present(viewController, animated: false)
    }
    
    /*
        Adds the view for shape options
    */
    func addShapeOptions(rectView: UIView) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let toolbarVC = storyboard.instantiateViewController(withIdentifier: "shapeOptions")
        
        /* Positioning of shape options view */
        //Screen size values for positioning of shape options view
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        
        //Toolbar size default
        let toolbarWidth: CGFloat = 250
        let toolbarHeight: CGFloat = 150
        
        //Maximum bounds (if shape too large for toolbar to stay on screen without covering)
        let minX: CGFloat = toolbarWidth / 2
        let minY: CGFloat = toolbarHeight / 2 + UIApplication.shared.statusBarFrame.height + 44
        let maxX: CGFloat = screenWidth - minX
        let maxY: CGFloat = screenHeight - toolbarHeight / 2 - 20
        
        //Distance from frame corner to circle edge
        let cornerDistanceX: CGFloat = (1/7) * rectView.frame.width
        let cornerDistanceY: CGFloat = (1/7) * rectView.frame.height
        
        //Shape corners positions
        let shapeXMin: CGFloat = rectView.center.x - rectView.frame.width / 2 - minX + cornerDistanceX
        let shapeYMin: CGFloat = rectView.center.y - rectView.frame.height / 2 + cornerDistanceY
        let shapeXMax: CGFloat = rectView.center.x + rectView.frame.width / 2 + minX - cornerDistanceX
        let shapeYMax: CGFloat = rectView.center.y + rectView.frame.height / 2 + toolbarHeight - cornerDistanceY
        
        toolbarVC.view.frame = CGRect(x: 0, y: 0, width: toolbarWidth, height: toolbarHeight)
        
        if (shapeXMin >= minX && shapeYMin >= minY) {
            toolbarVC.view.center = CGPoint(x: shapeXMin, y: shapeYMin)
        } else {
            if (shapeXMin >= minX && shapeYMax <= maxY) {
                toolbarVC.view.center = CGPoint(x: shapeXMin, y: shapeYMax)
            } else if (shapeXMax <= maxX && shapeYMin >= minY) {
                toolbarVC.view.center = CGPoint(x: shapeXMax, y: shapeYMin)
            } else if (shapeXMax <= maxX && shapeYMax <= maxY) {
                toolbarVC.view.center = CGPoint(x: shapeXMax, y: shapeYMax)
            } else {
                toolbarVC.view.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
            }
        }
        
        //Assign tag
        toolbarVC.view.tag = 1
        
        //Assign prefixes and default text
        defaultShapeOptions(view: toolbarVC.view, rectView: rectView)
        
        //Making the view look nice
        toolbarVC.view.layer.borderWidth = 1
        toolbarVC.view.layer.borderColor = UIColor.black.cgColor
        toolbarVC.view.layer.cornerRadius = 5
        
        //Add view and re-enable touch
        self.view.addSubview(toolbarVC.view)
        touchEnabled = false
    }
    
    
    /*
        Function for whenever a value is changed in one of the
        shape options text fields.
    */
    func textFieldChanged(field: Int) {
        let textField = self.view.viewWithTag(1)?.subviews[field] as! UITextField
        
        if let val = NumberFormatter().number(from: textField.text!) {
            switch field {
            case 1:
                currentShape?.updateWidth(width: CGFloat(truncating: val))
            case 2:
                currentShape?.updateHeight(height: CGFloat(truncating: val))
            case 3:
                currentShape?.updateX(x: CGFloat(truncating: val))
            case 4:
                currentShape?.updateY(y: CGFloat(truncating: val))
            default:
                print("Something went wrong")
                return
            }
        } else {
            textField.text = ""
        }
    }
    
    /*
        Creates the default values and views inside of the shape options view
    */
    func defaultShapeOptions(view: UIView, rectView: UIView) {
        
        //Creating prefixes for textfields
        let prefixWidth = UILabel()
        prefixWidth.text = "W: "
        prefixWidth.sizeToFit()
        let prefixHeight = UILabel()
        prefixHeight.text = "H: "
        prefixHeight.sizeToFit()
        let prefixX = UILabel()
        prefixX.text = "x: "
        prefixX.sizeToFit()
        let prefixY = UILabel()
        prefixY.text = "y: "
        prefixY.sizeToFit()
        
        //Default values for text views
        let widthInput = view.subviews[1] as! UITextField
        let heightInput = view.subviews[2] as! UITextField
        let xInput = view.subviews[3] as! UITextField
        let yInput = view.subviews[4] as! UITextField
        
        //Adding prefixes to textfields
        widthInput.leftView = prefixWidth
        widthInput.leftViewMode = .always
        heightInput.leftView = prefixHeight
        heightInput.leftViewMode = .always
        xInput.leftView = prefixX
        xInput.leftViewMode = .always
        yInput.leftView = prefixY
        yInput.leftViewMode = .always
        
        //Set default values of the textfields
        widthInput.text = "\(rectView.frame.width)"
        heightInput.text = "\(rectView.frame.height)"
        xInput.text = "\(rectView.frame.origin.x)"
        yInput.text = "\(rectView.frame.origin.y)"
    }
}
