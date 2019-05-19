//
//  ArtCanvas.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/14/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit
import CoreGraphics

class ArtCanvas: UIViewController, UIPopoverPresentationControllerDelegate {
    
    //Selected tool
    public static var modifiedShape: AbstractShapeView?
    public static var toolSelected: IndexPath = IndexPath(row: 0, section: 0)
    
    //User touch on screen
    var touchEnabled: Bool = true
    
    //Current shape being modified
    var currentShape: AbstractShapeView?
    
    //View controller
    //var toolbarVC: UIViewController?
    
    //Stamp tool enabled
    var showAdditionalOptions: Bool = true
    
    //Outlets and Actions
    @IBOutlet weak var toolbar: UIBarButtonItem!
    @IBAction func toolbarAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let toolbarVC = storyboard.instantiateViewController(withIdentifier: "toolbar")
        
        //Popover presentation style
        toolbarVC.modalPresentationStyle = .popover
        
        //Specify anchor point
        toolbarVC.popoverPresentationController?.barButtonItem = toolbar
        toolbarVC.preferredContentSize = CGSize(width: 74, height: UIScreen.main.bounds.height - 88)
        toolbarVC.popoverPresentationController?.delegate = self
        
        //Present popover
        self.present(toolbarVC, animated: false)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if (ArtCanvas.modifiedShape != nil) {
            imageView.addSubview(ArtCanvas.modifiedShape!)
            ArtCanvas.modifiedShape = nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touchEnabled) {
            if let touch = touches.first?.location(in: imageView) {
                switch ArtCanvas.toolSelected.row {
                case 0:
                    print("Circle")
                    let randomRectVal = CGRect(x: touch.x - 50, y: touch.y - 50, width: 100, height: 100)
                    let rectView = CircleView(frame: randomRectVal, identifier: "Circle1")
                    currentShape = rectView
                    imageView.addSubview(rectView)
                    
                    if (showAdditionalOptions) {
                        
                        // Code for showing more options
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let toolbarVC = storyboard.instantiateViewController(withIdentifier: "shapeOptions")
                        
                        //Popover presentation style
                        //toolbarVC.modalPresentationStyle = .popover
                        
                        //Specify anchor point
                        //if (UIDevice.current.userInterfaceIdiom == .phone) {
                        //    toolbarVC.popoverPresentationController?.barButtonItem = toolbar
                        //}
                        
                        //toolbarVC.popoverPresentationController?.sourceView = rectView
                        //toolbarVC.preferredContentSize = CGSize(width: 250, height: 150)
                        //toolbarVC.popoverPresentationController?.delegate = self
                        
                        //Screen size values for positioning of shape options view
                        let screenHeight: CGFloat = UIScreen.main.bounds.height
                        let screenWidth: CGFloat = UIScreen.main.bounds.width
                        
                        //Toolbar size
                        let toolbarWidth: CGFloat = 250
                        let toolbarHeight: CGFloat = 150
                        
                        //Maximum bounds (if shape too large for toolbar to stay on screen without covering:
                        let minX: CGFloat = toolbarWidth / 2
                        let minY: CGFloat = toolbarHeight / 2 + UIApplication.shared.statusBarFrame.height + 44
                        let maxX: CGFloat = screenWidth - minX
                        let maxY: CGFloat = screenHeight - toolbarHeight / 2 - 20
                        
                        //Use variables
                        //let useMinX: Bool = rectView.center.x >= screenWidth / 2
                        //let useMinY: Bool = rectView.center.y >= screenHeight / 2
                        
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
                            //toolbarVC.view.center = CGPoint(x: maxX, y: maxY)
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
                        /*
                        if (useMinX && useMinY) {
                            if (shapeXMin >= minX && shapeYMin >= minY) {
                                toolbarVC.view.center = CGPoint(x: shapeXMin, y: shapeYMin)
                            } else {
                                toolbarVC.view.center = CGPoint(x: minX, y: minY)
                            }
                        } else if (useMinX && !useMinY) {
                            if (shapeXMin >= minX && shapeYMax <= maxY) {
                                toolbarVC.view.center = CGPoint(x: shapeXMin, y: shapeYMax)
                            } else {
                                toolbarVC.view.center = CGPoint(x: minX, y: maxY)
                            }
                        } else if (!useMinX && useMinY) {
                            if (shapeXMax <= maxX && shapeYMin >= minY) {
                                toolbarVC.view.center = CGPoint(x: shapeXMax, y: shapeYMin)
                            } else {
                                toolbarVC.view.center = CGPoint(x: maxX, y: minY)
                            }
                        } else {
                            if (shapeXMax <= maxX && shapeYMax <= maxY) {
                                toolbarVC.view.center = CGPoint(x: shapeXMax, y: shapeYMax)
                            } else {
                                toolbarVC.view.center = CGPoint(x: maxX, y: maxY)
                            }
                        }*/
                        toolbarVC.view.tag = 1
                        
                        //Present popover
                        //self.present(toolbarVC, animated: false)
                        toolbarVC.view.layer.borderWidth = 1
                        toolbarVC.view.layer.borderColor = UIColor.black.cgColor
                        toolbarVC.view.layer.cornerRadius = 5
                        self.view.addSubview(toolbarVC.view)
                        touchEnabled = false
                    }
                case 1:
                    print("Rectangle")
                    let randomRectVal = CGRect(x: touch.x - 50, y: touch.y, width: 100, height: 100)
                    imageView.addSubview(RectangleView(frame: randomRectVal, identifier: "Rectangle1"))
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
    
    @IBAction func cancel(_ sender: Any) {
        //Remove current shape
        currentShape?.removeFromSuperview()
        currentShape = nil
        
        //Remove toolbar
        self.view.viewWithTag(1)?.removeFromSuperview()
        touchEnabled = true
    }
    
    @IBAction func done(_ sender: Any) {
        //Remove toolbar
        self.view.viewWithTag(1)?.removeFromSuperview()
        touchEnabled = true
    }
    
    //Shape options
    @IBOutlet weak var widthValue: UITextField!
    @IBAction func widthChanged(_ sender: Any) {
        let widthTextField = self.view.viewWithTag(1)?.subviews[1] as! UITextField
        
        currentShape?.removeFromSuperview()
        if let width = NumberFormatter().number(from: widthTextField.text!) {
            let newShape: AbstractShapeView = CircleView(frame: CGRect(x: currentShape!.frame.origin.x, y: currentShape!.frame.origin.y, width: CGFloat(truncating: width), height: CGFloat(truncating: width)), identifier: "Circle1")
            currentShape = newShape
            imageView.addSubview(newShape)
        } else {
            widthTextField.text = ""
        }
    }
    
    @IBOutlet weak var heightValue: UITextField!
    @IBAction func heightChanged(_ sender: Any) {
        
    }
    
    @IBOutlet weak var xValue: UITextField!
    @IBAction func xChanged(_ sender: Any) {
        
    }
    
    @IBOutlet weak var yValue: UITextField!
    @IBAction func yChanged(_ sender: Any) {
        
    }
    
}
