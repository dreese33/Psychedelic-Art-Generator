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
    
    //Move and resize bool array
    private static var moveAndResize: UInt8 = 0
    
    //Touch variables
    var firstTouchLocation: CGPoint?
    var resettableTouchLocation: CGPoint?
    var timesTouchesMoved: UInt8 = 0
    private static var firstTimeMoved: Bool = true
    
    //0 - none, 1 - left, 2 - right, 3 - up, 4 - down
    var sideMoveDirection: UInt8 = 0
    
    //0 - none, 1 - top left, 2 - bottom left, 3 - bottom right, 4 - top right
    var sidePressed: UInt8 = 0
    
    //Tool selected, modified in Toolbar class
    public static var toolSelected: IndexPath = IndexPath(row: 0, section: 0)
    
    //User touch on screen
    var touchEnabled: Bool = true
    
    //Current shape being modified
    public static var currentShape: AbstractShapeView?
    
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
    }
    
    //Code runs when tool selection is closed
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touchEnabled) {

            //Ensures touch is inside of image view
            if let touch = touches.first?.location(in: imageView) {
                
                //Reset touches moved values
                self.firstTouchLocation = touch
                self.resettableTouchLocation = touch
                self.sideMoveDirection = 0
                ArtCanvas.firstTimeMoved = true
                
                //Set side pressed
                if (ArtCanvas.currentShape != nil) {
                    if (touch.x > ArtCanvas.currentShape!.center.x) {
                        if (touch.y > ArtCanvas.currentShape!.center.y) {
                            print("Bottom right")
                            self.sidePressed = 3
                        } else {
                            print("Top right")
                            self.sidePressed = 4
                        }
                    } else {
                        if (touch.y > ArtCanvas.currentShape!.center.y) {
                            print("Bottom left")
                            self.sidePressed = 2
                        } else {
                            print("Top left")
                            self.sidePressed = 1
                        }
                    }
                }
                
                //Tool options
                switch ArtCanvas.toolSelected.row {
                case 0:
                    ArtCanvas.moveAndResize = 1
                    if (ArtCanvas.currentShape != nil) {
                        if (!ArtCanvas.currentShape!.frame.contains(touch)) {
                            ArtCanvas.currentShape!.center = touch
                        }
                    }
                case 1:
                    ArtCanvas.moveAndResize = 2
                case 2:
                    ArtCanvas.moveAndResize = 3
                case 3:
                    ArtCanvas.moveAndResize = 0
                    print("Circle")
                    
                    //Adds default circle to art canvas
                    let randomRectVal = CGRect(x: touch.x - 50, y: touch.y - 50, width: 100, height: 100)
                    let rectView = CircleView(frame: randomRectVal, identifier: "Circle1")
                    ArtCanvas.currentShape = rectView
                    imageView.addSubview(rectView)
                    
                    if (showAdditionalOptions) {
                        
                        //Adds shape options view
                        addShapeOptions(rectView: rectView)
                    }
                case 4:
                    ArtCanvas.moveAndResize = 0
                    print("Rectangle")
                    let randomRectVal = CGRect(x: touch.x - 50, y: touch.y - 50, width: 100, height: 100)
                    let rectView = RectangleView(frame: randomRectVal, identifier: "Rectangle1")
                    ArtCanvas.currentShape = rectView
                    imageView.addSubview(rectView)
                    
                    if (showAdditionalOptions) {
                        
                        //Adds shape options view
                        addShapeOptions(rectView: rectView)
                    }
                case 5:
                    ArtCanvas.moveAndResize = 0
                    print("Pentagon")
                case 6:
                    print("Star")
                default:
                    print("Something went wrong")
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (ArtCanvas.moveAndResize != 0) {
            
            touchEnabled = true
            if (ArtCanvas.currentShape != nil) {
                if let touch = touches.first?.location(in: self.imageView!) {
                    switch ArtCanvas.moveAndResize {
                    case 1:
                        print("Move")
                        
                        if ArtCanvas.currentShape!.frame.contains(touch) {
                            //Calculate distance from last touch, then move shape accordingly
                            let distanceMoved = CGPoint(x: touch.x - self.firstTouchLocation!.x, y: touch.y - self.firstTouchLocation!.y)
                            self.firstTouchLocation = touch
                            ArtCanvas.currentShape!.center = CGPoint(x: ArtCanvas.currentShape!.center.x + distanceMoved.x, y: ArtCanvas.currentShape!.center.y + distanceMoved.y)
                        } else {
                            ArtCanvas.currentShape!.center = touch
                        }
                        
                    case 2:
                        print("Resize Sideways")
                        
                        self.resettableTouchLocation = touch
                        if (self.timesTouchesMoved == 4) {
                            
                            self.timesTouchesMoved = 0
                        }
                        
                    case 3:
                        //print("Resize Horizontal")
                        
                        
                        if (ArtCanvas.firstTimeMoved) {
                            self.firstTouchLocation = touch
                            ArtCanvas.firstTimeMoved = false
                        }
 
                        //Set initial touch
                        if (self.timesTouchesMoved == 0) {
                            self.resettableTouchLocation = touch
                        }
                        
                        //No direction selected yet, collect 10 points of information, then move it
                        if (self.sideMoveDirection == 0) {
                            
                            if (self.timesTouchesMoved == 10) {
                                
                                //Set side move direction
                                let xDifference = self.resettableTouchLocation!.x - touch.x
                                let yDifference = self.resettableTouchLocation!.y - touch.y
                                
                                if (xDifference > 0 && yDifference > 0) {
                                    if (xDifference == yDifference) {
                                        //print("No movement")
                                        self.sideMoveDirection = 0
                                    } else if (xDifference > yDifference) {
                                        //print("Left")
                                        self.sideMoveDirection = 1
                                    } else {
                                        //print("Up")
                                        self.sideMoveDirection = 3
                                    }
                                } else if (xDifference < 0 && yDifference < 0) {
                                    if (xDifference == yDifference) {
                                        //print("No movement")
                                        self.sideMoveDirection = 0
                                    } else if (xDifference < yDifference) {
                                        //print("Right")
                                        self.sideMoveDirection = 2
                                    } else {
                                        //print("Down")
                                        self.sideMoveDirection = 4
                                    }
                                } else {
                                    let difference = xDifference + yDifference
                                    if (difference == 0) {
                                        //print("No movement")
                                        self.sideMoveDirection = 0
                                    } else if (xDifference > 0) {
                                        if (difference > 0) {
                                            //print("Left")
                                            self.sideMoveDirection = 1
                                        } else {
                                            //print("Down")
                                            self.sideMoveDirection = 4
                                        }
                                    } else {
                                        if (difference > 0) {
                                            //print("Up")
                                            self.sideMoveDirection = 3
                                        } else {
                                            //print("Right")
                                            self.sideMoveDirection = 2
                                        }
                                    }
                                }
                                
                                self.timesTouchesMoved = 0
                            } else {
                                self.timesTouchesMoved += 1
                            }
                        } else {
                            
                            //Change scaling from shrinking to expanding
                            if (self.timesTouchesMoved == 6) {
                                
                                self.timesTouchesMoved = 0
                                
                                if (self.sideMoveDirection == 1 || self.sideMoveDirection == 2) {
                                    let xDifference = self.resettableTouchLocation!.x - touch.x
                                    if (xDifference < 0) {
                                        //print("Right")
                                        self.sideMoveDirection = 2
                                    } else {
                                        //print("Left")
                                        self.sideMoveDirection = 1
                                    }
                                } else {
                                    let yDifference = self.resettableTouchLocation!.y - touch.y
                                    if (yDifference < 0) {
                                        //print("Down")
                                        self.sideMoveDirection = 4
                                    } else {
                                        //print("Up")
                                        self.sideMoveDirection = 3
                                    }
                                }
                            } else {
                                self.timesTouchesMoved += 1
                            }
                            
                            //Apply transform
                            let newWidthGrow = abs(touch.x - ArtCanvas.currentShape!.frame.origin.x) + ArtCanvas.currentShape!.frame.width
                            
                            let newWidthShrink = ArtCanvas.currentShape!.frame.width - abs(touch.x - ArtCanvas.currentShape!.frame.origin.x)
                            
                            let newHeightGrow = ArtCanvas.currentShape!.frame.height + abs(ArtCanvas.currentShape!.frame.origin.y - touch.y)
                            
                            let newHeightShrink = ArtCanvas.currentShape!.frame.height - abs(touch.y - ArtCanvas.currentShape!.frame.origin.y)
                            
                            switch self.sideMoveDirection {
                            case 1:
                                print("Left")
                                
                                if (self.sidePressed == 1 || self.sidePressed == 2) {
                                    //Grow left
                                    ArtCanvas.currentShape!.frame = CGRect(x: touch.x, y: ArtCanvas.currentShape!.frame.origin.y, width: newWidthGrow, height: ArtCanvas.currentShape!.frame.height)
                                } else {
                                    //Shrink left
                                    ArtCanvas.currentShape!.frame = CGRect(x: ArtCanvas.currentShape!.frame.origin.x, y: ArtCanvas.currentShape!.frame.origin.y, width: abs(touch.x - ArtCanvas.currentShape!.frame.origin.x), height: ArtCanvas.currentShape!.frame.height)
                                }
                            case 2:
                                print("Right")
                                if (self.sidePressed == 1 || self.sidePressed == 2) {
                                    //Shrink right
                                    ArtCanvas.currentShape!.frame = CGRect(x: touch.x, y: ArtCanvas.currentShape!.frame.origin.y, width: newWidthShrink, height: ArtCanvas.currentShape!.frame.height)
                                } else {
                                    //Grow right
                                    ArtCanvas.currentShape!.frame = CGRect(x: ArtCanvas.currentShape!.frame.origin.x, y: ArtCanvas.currentShape!.frame.origin.y, width: abs(touch.x - ArtCanvas.currentShape!.frame.origin.x), height: ArtCanvas.currentShape!.frame.height)
                                }
                            case 3:
                                print("Up")
                                if (self.sidePressed == 1 || self.sidePressed == 4) {
                                    //Grow up
                                    ArtCanvas.currentShape!.frame = CGRect(x: ArtCanvas.currentShape!.frame.origin.x, y: touch.y, width: ArtCanvas.currentShape!.frame.width, height: newHeightGrow)
                                } else {
                                    //Shrink up
                                    ArtCanvas.currentShape!.frame = CGRect(x: ArtCanvas.currentShape!.frame.origin.x, y: ArtCanvas.currentShape!.frame.origin.y, width: ArtCanvas.currentShape!.frame.width, height: abs(touch.y - ArtCanvas.currentShape!.frame.origin.y))
                                }
                            case 4:
                                print("Down")
                                if (self.sidePressed == 1 || self.sidePressed == 4) {
                                    //Shrink down
                                    print("Shrink Down")
                                    ArtCanvas.currentShape!.frame = CGRect(x: ArtCanvas.currentShape!.frame.origin.x, y: touch.y, width: ArtCanvas.currentShape!.frame.width, height: newHeightShrink)
                                } else {
                                    //Grow down
                                    print("Grow Down")
                                    ArtCanvas.currentShape!.frame = CGRect(x: ArtCanvas.currentShape!.frame.origin.x, y: ArtCanvas.currentShape!.frame.origin.y, width: ArtCanvas.currentShape!.frame.width, height: abs(ArtCanvas.currentShape!.frame.origin.y - touch.y))
                                }
                            default:
                                print("Something went wrong")
                            }
                            
                            self.firstTouchLocation = touch
                        }
                    default:
                        print("No transformation")
                    }
                }
            }
        }
    }
    
    
    //Cancel action, removes added shape
    @IBAction func cancel(_ sender: Any) {
        //Remove current shape
        ArtCanvas.currentShape?.removeFromSuperview()
        ArtCanvas.currentShape = nil
        
        NewObjectConfigurationFromTable.additionalShape = nil
        
        //Remove toolbar
        self.view.viewWithTag(1)?.removeFromSuperview()
        touchEnabled = true
    }
    
    //Done action, completes adding shape
    @IBAction func done(_ sender: Any) {
        //Remove toolbar
        self.view.viewWithTag(1)?.removeFromSuperview()
        touchEnabled = true
        
        NewObjectConfigurationFromTable.additionalShape = nil
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
        } else {
            viewController.popoverPresentationController?.sourceView = self.view
            viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
                ArtCanvas.currentShape?.updateWidth(width: CGFloat(truncating: val))
            case 2:
                ArtCanvas.currentShape?.updateHeight(height: CGFloat(truncating: val))
            case 3:
                ArtCanvas.currentShape?.updateX(x: CGFloat(truncating: val))
            case 4:
                ArtCanvas.currentShape?.updateY(y: CGFloat(truncating: val))
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
