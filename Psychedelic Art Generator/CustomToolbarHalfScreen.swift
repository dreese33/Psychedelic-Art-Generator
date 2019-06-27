//
//  CustomToolbarHalfScreen.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 6/24/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit

class CustomToolbarHalfScreen: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var toolbarTableView: UITableView!
    @IBOutlet weak var uselessHalfView: UIView!
    
    //Subcategories for toolbar
    private let shapesSubviews: [UIImageView] = [UIImageView(image: UIImage(named: "Circle")!), UIImageView(image: UIImage(named: "Rectangle")!), UIImageView(image: UIImage(named: "Pentagon")!), UIImageView(image: UIImage(named: "Star")!)]
    
    private let editSubviews: [UIImageView] = [UIImageView(image: UIImage(named: "Move")!), UIImageView(image: UIImage(named: "ResizeSide")!), UIImageView(image: UIImage(named: "ResizeHorizontal")!)]
    
    private let toolArray: [String] = ["Shapes", "Edit Shapes"]
    private let moreOptionsToolArray: [String] = ["Color"]
    
    var tableCellHeight: CGFloat = 0.0
    
    private var subcategoriesVisible = false
    private var cellSelected = false
    private var mostRecentToolSelected = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.uselessHalfView.backgroundColor = UIColor.clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(uselessviewTapped))
        self.uselessHalfView.addGestureRecognizer(tap)
        
        self.toolbarTableView.translatesAutoresizingMaskIntoConstraints = false
        self.uselessHalfView.translatesAutoresizingMaskIntoConstraints = false
        
        self.toolbarTableView.delegate = self
        self.toolbarTableView.dataSource = self
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            tableCellHeight = UIScreen.main.bounds.height / 20
        } else {
            tableCellHeight = UIScreen.main.bounds.height / 15
        }
        
        addToolbarSubviews()
        hideAllSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (NewObjectConfigurationFromTable.newToolbarActivated) {
            self.toolbarTableView.selectRow(at: NewObjectConfigurationFromTable.toolSelected, animated: true, scrollPosition: .top)
        } else {
            self.mostRecentToolSelected = ArtCanvas.toolSelected
            self.toolbarTableView.selectRow(at: ArtCanvas.toolSelected, animated: true, scrollPosition: .top)
            self.subviewLogic(indexPath: ArtCanvas.toolSelected)
            self.highlightAppropriateSubview()
            self.cellSelected = true
        }
        
        super.viewDidAppear(animated)
    }
    
    @objc func uselessviewTapped(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: uselessHalfView)
        var index = 0
        var dismissing = true
        
        switch mostRecentToolSelected.row {
        case 0:
            for imageSubview in shapesSubviews {
                if imageSubview.frame.contains(location) {
                    dismissing = false
                    ArtCanvas.toolSelected = mostRecentToolSelected
                    
                    if (ArtCanvas.subcategorySelected != -1 && ArtCanvas.subcategorySelected < shapesSubviews.count) {
                        self.shapesSubviews[ArtCanvas.subcategorySelected].backgroundColor = UIColor.white
                    }
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        imageSubview.backgroundColor = UIColor.gray
                    }, completion: { (finished: Bool) in
                        ArtCanvas.subcategorySelected = index
                    })
                    break
                }
                
                index += 1
            }
        case 1:
            for imageSubview in editSubviews {
                if imageSubview.frame.contains(location) {
                    dismissing = false
                    ArtCanvas.toolSelected = mostRecentToolSelected
                    
                    if (ArtCanvas.subcategorySelected != -1 && ArtCanvas.subcategorySelected < editSubviews.count) {
                        self.editSubviews[ArtCanvas.subcategorySelected].backgroundColor = UIColor.white
                    }
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        imageSubview.backgroundColor = UIColor.gray
                    }, completion: { (finished: Bool) in
                        ArtCanvas.subcategorySelected = index
                    })
                    break
                }
                
                index += 1
            }
        default:
            print("Something went wrong")
        }
        
        if (dismissing) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Highlights the selected subview
    private func highlightAppropriateSubview() {
        if (ArtCanvas.subcategorySelected != -1) {
            switch ArtCanvas.toolSelected.row {
            case 0:
                UIView.animate(withDuration: 0.25, animations: {
                    self.shapesSubviews[ArtCanvas.subcategorySelected].backgroundColor = UIColor.gray
                })
            case 1:
                UIView.animate(withDuration: 0.25, animations: {
                    self.editSubviews[ArtCanvas.subcategorySelected].backgroundColor = UIColor.gray
                })
            default:
                print("Something went wrong")
            }
        }
    }
    
    //Table view functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (NewObjectConfigurationFromTable.newToolbarActivated) {
            return moreOptionsToolArray.count
        } else {
            return toolArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (NewObjectConfigurationFromTable.newToolbarActivated) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toolCell")
            cell?.textLabel?.center = cell!.center
            cell?.textLabel?.text = moreOptionsToolArray[indexPath.row]
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toolCell")
            cell!.textLabel?.text = toolArray[indexPath.row]
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Set IndexPath for ArtCanvas class
        if (NewObjectConfigurationFromTable.newToolbarActivated) {
            NewObjectConfigurationFromTable.toolSelected = indexPath
        } else {
            if (cellSelected) {
                if (mostRecentToolSelected.row == indexPath.row) {
                    cellSelected = false
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else {
                cellSelected = true
                highlightAppropriateSubview()
            }
            
            subviewLogic(indexPath: indexPath)
            mostRecentToolSelected = indexPath
        }
    }
    
    //Ensures that subviews are placed properly on screen
    private func subviewLogic(indexPath: IndexPath) {
        
        if (subcategoriesVisible) {
            hideAllSubviews()
        }
        
        switch indexPath.row {
        case 0:
            if (!subcategoriesVisible || indexPath.row != mostRecentToolSelected.row) {
                subcategoriesVisible = true
                self.revealShapeSubviews()
            } else {
                subcategoriesVisible = false
            }
        case 1:
            if (!subcategoriesVisible || indexPath.row != mostRecentToolSelected.row) {
                subcategoriesVisible = true
                self.revealEditSubviews()
            } else {
                subcategoriesVisible = false
            }
        default:
            print("Something wrong")
        }
    }
    
    //Popover presentation capabilities
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCellHeight
    }
    
    private func addToolbarSubviews() {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        for imageViewShape in shapesSubviews {
            imageViewShape.frame = CGRect(x: currentX, y: currentY, width: tableCellHeight, height: tableCellHeight)
            imageViewShape.layer.borderWidth = 1
            imageViewShape.backgroundColor = UIColor.white
            uselessHalfView.addSubview(imageViewShape)
            currentX += tableCellHeight
        }
        
        currentX = 0
        currentY += tableCellHeight
        
        for imageViewShape in editSubviews {
            imageViewShape.frame = CGRect(x: currentX, y: currentY, width: tableCellHeight, height: tableCellHeight)
            imageViewShape.layer.borderWidth = 1
            imageViewShape.backgroundColor = UIColor.white
            uselessHalfView.addSubview(imageViewShape)
            currentX += tableCellHeight
        }
    }
    
    private func hideShapeSubviews() {
        for imageViewShape in shapesSubviews {
            imageViewShape.isHidden = true
        }
    }
    
    private func revealShapeSubviews() {
        for imageViewShape in shapesSubviews {
            imageViewShape.isHidden = false
        }
    }
    
    private func hideEditSubviews() {
        for imageViewSubview in editSubviews {
            imageViewSubview.isHidden = true
        }
    }
    
    private func revealEditSubviews() {
        for imageViewSubview in editSubviews {
            imageViewSubview.isHidden = false
        }
    }
    
    private func hideAllSubviews() {
        hideShapeSubviews()
        hideEditSubviews()
    }
}
