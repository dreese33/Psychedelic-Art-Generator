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
    
    //Possibly delete these variables, organize them later once completely integrated into the application
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var settingsButton: UIButton!
    let doubleSlider = DoubleSlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let doubleSliderVertical = DoubleSlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0), orientation: .vertical)
    let collapseHorizontalSlider = UIImageView(image: UIImage(named: "ColorWheelArrow"))
    let collapseVerticalSlider = UIImageView(image: UIImage(named: "ColorWheelArrow"))
    var featuresNotLoaded: Bool = true
    
    //Collapse sliders logic
    private var horizontalSliderCollapsed: Bool = false
    private var verticalSliderCollapsed: Bool = false
    
    //Transition
    private var shiftTransitioningDelegate: ShiftScreenTransitioningDelegate!
    
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
        //displayViewController(identifier: "toolbar")
        displayViewController(identifier: "customToolbarHalfScreen")
    }
    
    //Popover presentation enabled
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Default override
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // let collapseImage = UIImage(named: "ColorWheelArrow")
        
       // imageViewVertical = UIImageView(image: collapseImage)
        //imageViewHorizontal = UIImageView(image: collapseImage)
        
        //self.view.addSubview(imageViewVertical!)
        //self.view.addSubview(imageViewHorizontal!)
        
        //Add custom double slider
        doubleSlider.isHidden = true
        self.view.addSubview(doubleSlider)
        doubleSlider.addTarget(self, action: #selector(doubleSliderValueChanged(doubleSlider:)), for: .valueChanged)
        
        //Add custom vertical double slider
        doubleSliderVertical.isHidden = true
        self.view.addSubview(doubleSliderVertical)
        doubleSliderVertical.addTarget(self, action: #selector(doubleSliderValueChanged(doubleSlider:)), for: .valueChanged)
        //print("height: \(UIScreen.main.bounds.height) width: \(UIScreen.main.bounds.width)")
    }
    
    @objc func doubleSliderValueChanged(doubleSlider: DoubleSlider) {
        print("Double slider value changed: (\(doubleSlider.lowerValue) \(doubleSlider.upperValue))")
        let relativeThumbSize: Double!
        if (doubleSlider.alignment == .horizontal) {
            relativeThumbSize = Double(doubleSlider.thumbWidth / UIScreen.main.bounds.width)
        } else {
            relativeThumbSize = Double(doubleSlider.thumbWidth / UIScreen.main.bounds.height)
        }
        
        let thumbPosUpper = doubleSlider.upperValue - relativeThumbSize
        let thumbPosLower = doubleSlider.lowerValue + relativeThumbSize
        if (doubleSlider.lowerValue > thumbPosUpper) {
            doubleSlider.lowerValue = thumbPosUpper
        } else if (doubleSlider.upperValue < thumbPosLower) {
            doubleSlider.upperValue = thumbPosLower
        }
        
        //Prevent slider thumbs from going off slider
        if (doubleSlider.lowerValue < 0.0) {
            doubleSlider.lowerValue = 0.0
        }
        
        if (doubleSlider.upperValue < relativeThumbSize) {
            doubleSlider.upperValue = relativeThumbSize
        }
        
        if (doubleSlider.upperValue > 1.0) {
            doubleSlider.upperValue = 1.0
        }
        
        if (doubleSlider.lowerValue > 1.0 - relativeThumbSize) {
            doubleSlider.lowerValue = 1.0 - relativeThumbSize
        }
        
        updateCurrentShapeSize(alignment: doubleSlider.alignment!)
    }
    
    override func viewDidLayoutSubviews() {
        let width = view.bounds.width
        let height = view.bounds.height
        doubleSlider.frame = CGRect(x: 0, y: view.bounds.height - 50,
                                   width: width, height: 50)
        doubleSliderVertical.frame = CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //Code runs when tool selection is closed
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (self.featuresNotLoaded) {
            //Collapse features for sliders
            imageView.addSubview(collapseVerticalSlider)
            imageView.addSubview(collapseHorizontalSlider)
        
            collapseHorizontalSlider.isHidden = true
            collapseVerticalSlider.isHidden = true
        
            collapseHorizontalSlider.frame = CGRect(x: doubleSlider.thumbWidth / 2, y: imageView.bounds.height - 75, width: 25, height: 25)
            collapseVerticalSlider.frame = CGRect(x: imageView.bounds.width - 75, y: doubleSliderVertical.thumbWidth / 2, width: 25, height: 25)
            collapseVerticalSlider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
            
            self.featuresNotLoaded = false
        }
        
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
                    
                    print("vertical: \(collapseVerticalSlider.frame) horizontal: \(collapseHorizontalSlider.frame) touch: \(touch)")
                    
                    //Collapse sliders
                    if (collapseHorizontalSlider.frame.contains(touch)) {
                        if (!horizontalSliderCollapsed) {
                            collapseHorizontalSlider.transform = CGAffineTransform(rotationAngle: .pi)
                            UIView.animate(withDuration: 0.25, animations: {
                                self.doubleSlider.frame.origin = CGPoint(x: self.doubleSlider.frame.origin.x, y: UIScreen.main.bounds.height)
                                self.collapseHorizontalSlider.frame.origin = CGPoint(x: self.collapseHorizontalSlider.frame.origin.x, y: self.imageView.bounds.height - 25)
                            })
                            
                            horizontalSliderCollapsed = true
                        } else {
                            collapseHorizontalSlider.transform = CGAffineTransform(rotationAngle: 0)
                            UIView.animate(withDuration: 0.25, animations: {
                                self.doubleSlider.frame.origin = CGPoint(x: 0, y: self.view.bounds.height - 50)
                                self.collapseHorizontalSlider.frame.origin = CGPoint(x: self.doubleSlider.thumbWidth / 2, y: self.imageView.bounds.height - 75)
                            })
                            
                            horizontalSliderCollapsed = false
                        }
                    } else if (collapseVerticalSlider.frame.contains(touch)) {
                        if (!verticalSliderCollapsed) {
                            collapseVerticalSlider.transform = CGAffineTransform(rotationAngle: .pi / 2)
                            UIView.animate(withDuration: 0.25, animations: {
                                self.doubleSliderVertical.frame.origin = CGPoint(x: self.imageView.bounds.width, y: self.doubleSliderVertical.frame.origin.y)
                                self.collapseVerticalSlider.frame.origin = CGPoint(x: UIScreen.main.bounds.width - 25, y: self.collapseVerticalSlider.frame.origin.y)
                            })
                            
                            verticalSliderCollapsed = true
                        } else {
                            collapseVerticalSlider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
                            UIView.animate(withDuration: 0.25, animations: {
                                self.doubleSliderVertical.frame.origin = CGPoint(x: self.view.bounds.width - 50, y: 0)
                                self.collapseVerticalSlider.frame.origin = CGPoint(x: self.imageView.bounds.width - 75, y: self.doubleSliderVertical.thumbWidth / 2)
                            })
                            
                            verticalSliderCollapsed = false
                        }
                    } else {
                        //print("Else")
                        if (ArtCanvas.currentShape != nil) {
                            if (!ArtCanvas.currentShape!.frame.contains(touch)) {
                                ArtCanvas.currentShape!.center = touch
                            }
                        }
                    
                        if (ArtCanvas.currentShape != nil) {
                            revealSliders()
                        }
                    }
                case 1:
                    ArtCanvas.moveAndResize = 2
                    hideSliders()
                case 2:
                    ArtCanvas.moveAndResize = 3
                    
                    if (ArtCanvas.currentShape != nil) {
                        revealSliders()
                    }
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
                    
                    hideSliders()
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
                    
                    hideSliders()
                case 5:
                    ArtCanvas.moveAndResize = 0
                    print("Pentagon")
                    
                    hideSliders()
                case 6:
                    print("Star")
                    
                    hideSliders()
                default:
                    print("Something went wrong")
                    hideSliders()
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
                        if ArtCanvas.currentShape!.frame.contains(touch) {
                            //Calculate distance from last touch, then move shape accordingly
                            let distanceMoved = CGPoint(x: touch.x - self.firstTouchLocation!.x, y: touch.y - self.firstTouchLocation!.y)
                            self.firstTouchLocation = touch
                            ArtCanvas.currentShape!.center = CGPoint(x: ArtCanvas.currentShape!.center.x + distanceMoved.x, y: ArtCanvas.currentShape!.center.y + distanceMoved.y)
                        } else {
                            ArtCanvas.currentShape!.center = touch
                        }
                        
                        updateSliders()
                        
                    case 2:
                        print("Resize Sideways")
                        
                        self.resettableTouchLocation = touch
                        if (self.timesTouchesMoved == 4) {
                            
                            self.timesTouchesMoved = 0
                        }
                        
                    case 3:
                        print("Resize Horizontal")
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
        
        //Specify anchor point
        
        if (identifier == "toolbar") {
            viewController.preferredContentSize = CGSize(width: 74, height: UIScreen.main.bounds.height - 88)
            
            //Popover presentation style
            shiftTransitioningDelegate = ShiftScreenTransitioningDelegate(from: self, to: viewController)
            shiftTransitioningDelegate.direction = .left
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = shiftTransitioningDelegate
            
            //Present popover
            self.present(viewController, animated: true)
        } else if (identifier == "customToolbarHalfScreen") {
            //Custom presentation style
            shiftTransitioningDelegate = ShiftScreenTransitioningDelegate(from: self, to: viewController)
            shiftTransitioningDelegate.direction = .left
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = shiftTransitioningDelegate
            
            //Present custom presentation
            self.present(viewController, animated: true)
        } else {
            viewController.popoverPresentationController?.sourceView = self.view
            viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            self.present(viewController, animated: false)
            //Popover presentation style
           // viewController.modalPresentationStyle = .popover
        }
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
    
    func revealSliders() {
        updateSliders()
        settingsButton.isHidden = true
        doubleSlider.isHidden = false
        doubleSliderVertical.isHidden = false
        collapseHorizontalSlider.isHidden = false
        collapseVerticalSlider.isHidden = false
    }
    
    func hideSliders() {
        settingsButton.isHidden = false
        doubleSlider.isHidden = true
        doubleSliderVertical.isHidden = true
        collapseHorizontalSlider.isHidden = true
        collapseVerticalSlider.isHidden = true
    }
    
    func updateSliders() {
        let relativeThumbSizeHorizontal = Double(doubleSlider.thumbWidth / UIScreen.main.bounds.width)
        let relativeThumbSizeVertical = Double(doubleSlider.thumbWidth / UIScreen.main.bounds.height)
        
        //Once end is reached on either side, thumbheight is amount it is off by
        let horizontalScreenPercentage = Double(ArtCanvas.currentShape!.frame.origin.x / doubleSlider.frame.width)
        let verticalScreenPercentage = Double(ArtCanvas.currentShape!.frame.origin.y / doubleSliderVertical.frame.height)
        let horizontalScreenPercentageWidth = Double((ArtCanvas.currentShape!.frame.origin.x + ArtCanvas.currentShape!.frame.width) / doubleSlider.frame.width)
        let verticalScreenPercentageHeight = Double((ArtCanvas.currentShape!.frame.origin.y + ArtCanvas.currentShape!.frame.height) / doubleSliderVertical.frame.height)
        
        let horizontalThumbFactor = Double(relativeThumbSizeHorizontal) * Double(0.5 - horizontalScreenPercentage)
        let verticalThumbFactor = Double(relativeThumbSizeVertical) * Double(0.5 - verticalScreenPercentage)
        let horizontalThumbFactorWidth = Double(relativeThumbSizeHorizontal) * Double(0.5 - horizontalScreenPercentageWidth)
        let verticalThumbFactorHeight = Double(relativeThumbSizeVertical) * Double(0.5 - verticalScreenPercentageHeight)
        
        //print("Horizontal: \(horizontalThumbFactor)   Vertical: \(verticalThumbFactor)")
        
        doubleSlider.lowerValue = Double((ArtCanvas.currentShape!.frame.origin.x) / (doubleSlider.frame.width)) - horizontalThumbFactor
        doubleSlider.upperValue = Double((ArtCanvas.currentShape!.frame.origin.x + ArtCanvas.currentShape!.frame.width) / (doubleSlider.frame.width)) - horizontalThumbFactorWidth
        doubleSliderVertical.lowerValue = Double((ArtCanvas.currentShape!.frame.origin.y + 44 + doubleSlider.thumbWidth / 4 + UIApplication.shared.statusBarFrame.height) / doubleSliderVertical.frame.height) - verticalThumbFactor
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            doubleSliderVertical.upperValue = Double((ArtCanvas.currentShape!.frame.origin.y + 44 + UIApplication.shared.statusBarFrame.height + ArtCanvas.currentShape!.frame.height) / doubleSliderVertical.frame.height) - verticalThumbFactorHeight
        } else {
            doubleSliderVertical.upperValue = Double((ArtCanvas.currentShape!.frame.origin.y + 44 + UIApplication.shared.statusBarFrame.height + ArtCanvas.currentShape!.frame.height + doubleSlider.thumbWidth / 4) / doubleSliderVertical.frame.height) - verticalThumbFactorHeight
        }
    }
    
    
    func updateCurrentShapeSize(alignment: Alignment) {
        
        let irrelevantScreenHeightFactor = (44 + UIApplication.shared.statusBarFrame.height) / doubleSliderVertical.frame.height
        
        let relativeThumbSizeHorizontal = Double(doubleSlider.thumbWidth / UIScreen.main.bounds.width)
        let relativeThumbSizeVertical = Double(doubleSlider.thumbWidth / UIScreen.main.bounds.height)
        
        //Once end is reached on either side, thumbheight is amount it is off by
        
        let horizontalScreenPercentage = Double(ArtCanvas.currentShape!.frame.origin.x / doubleSlider.frame.width)
        let verticalScreenPercentage = Double(ArtCanvas.currentShape!.frame.origin.y / doubleSliderVertical.frame.height)
        let horizontalScreenPercentageWidth = Double((ArtCanvas.currentShape!.frame.origin.x + ArtCanvas.currentShape!.frame.width) / doubleSlider.frame.width)
        let verticalScreenPercentageHeight = Double((ArtCanvas.currentShape!.frame.origin.y + ArtCanvas.currentShape!.frame.height) / doubleSliderVertical.frame.height)
        
        let horizontalThumbFactor = CGFloat(relativeThumbSizeHorizontal) * (CGFloat(0.5 - horizontalScreenPercentage))
        let verticalThumbFactor = CGFloat(relativeThumbSizeVertical) * (CGFloat(0.5 - verticalScreenPercentage))
        let horizontalThumbFactorWidth = CGFloat(relativeThumbSizeHorizontal) * (CGFloat(0.5 - horizontalScreenPercentageWidth))
        let verticalThumbFactorHeight = CGFloat(relativeThumbSizeVertical) * (CGFloat(0.5 - verticalScreenPercentageHeight))
        
        var xVal: CGFloat!
        var yVal: CGFloat!
        var widthVal: CGFloat!
        var heightVal: CGFloat!
        
        xVal = (CGFloat(doubleSlider.lowerValue) + horizontalThumbFactor) * doubleSlider.frame.width
        yVal = (CGFloat(doubleSliderVertical.lowerValue) - irrelevantScreenHeightFactor - CGFloat(relativeThumbSizeVertical / 4) + verticalThumbFactor) * doubleSliderVertical.frame.height
        widthVal = ((CGFloat(doubleSlider.upperValue) + horizontalThumbFactorWidth) - (CGFloat(doubleSlider.lowerValue) + horizontalThumbFactor)) * doubleSlider.frame.width
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            heightVal = (CGFloat(doubleSliderVertical.upperValue) + verticalThumbFactorHeight - (CGFloat(doubleSliderVertical.lowerValue) + verticalThumbFactor) + CGFloat(relativeThumbSizeVertical / 4)) * doubleSliderVertical.frame.height
        } else {
             heightVal = (CGFloat(doubleSliderVertical.upperValue) + verticalThumbFactorHeight - (CGFloat(doubleSliderVertical.lowerValue) + verticalThumbFactor)) * doubleSliderVertical.frame.height
        }
        
        ArtCanvas.currentShape!.frame = CGRect(x: xVal, y: yVal, width: widthVal, height: heightVal)
    }
}
