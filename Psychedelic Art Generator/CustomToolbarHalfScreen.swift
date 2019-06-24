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
    public static var shapesSubviews: [UIImageView] = [UIImageView(image: UIImage(named: "Circle")!), UIImageView(image: UIImage(named: "Rectangle")!), UIImageView(image: UIImage(named: "Pentagon")!), UIImageView(image: UIImage(named: "Star")!)]
    
    //Tool arrays for tools and shape options
    private final let toolArray: [UIImage] = [UIImage(named: "Move")!, UIImage(named: "ResizeSide")!, UIImage(named: "ResizeHorizontal")!, UIImage(named: "Circle")!, UIImage(named: "Rectangle")!, UIImage(named: "Pentagon")!, UIImage(named: "Star")!, UIImage(named: "Circle")!]
    private final let moreOptionsToolArray: [String] = ["Color"]
    
    var previousRowSelected = 0
    var subcategoriesVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.uselessHalfView.backgroundColor = UIColor.clear
        
        self.toolbarTableView.translatesAutoresizingMaskIntoConstraints = false
        self.uselessHalfView.translatesAutoresizingMaskIntoConstraints = false
        
        self.toolbarTableView.delegate = self
        self.toolbarTableView.dataSource = self
        
        addShapeSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (NewObjectConfigurationFromTable.newToolbarActivated) {
            self.toolbarTableView.selectRow(at: NewObjectConfigurationFromTable.toolSelected, animated: true, scrollPosition: .top)
        } else {
            self.toolbarTableView.selectRow(at: ArtCanvas.toolSelected, animated: true, scrollPosition: .top)
        }
        
        super.viewDidAppear(animated)
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
            cell!.imageView!.center = cell!.center
            cell!.imageView!.image = toolArray[indexPath.row]
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Set IndexPath for ArtCanvas class
        if (NewObjectConfigurationFromTable.newToolbarActivated) {
            NewObjectConfigurationFromTable.toolSelected = indexPath
        } else {
            ArtCanvas.toolSelected = indexPath
        }
    }
    
    //Popover presentation capabilities
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    private func addShapeSubviews() {
        var currentX = UIScreen.main.bounds.width / 3
        for imageViewShape in CustomToolbarHalfScreen.shapesSubviews {
            imageViewShape.frame = CGRect(x: currentX, y: 100, width: 50, height: 50)
            imageViewShape.layer.borderWidth = 1
            imageViewShape.backgroundColor = UIColor.white
            //uselessHalfView.addSubview(imageViewShape)
            self.view.addSubview(imageViewShape)
            currentX += 50
        }
    }
    
    public static func hideShapeSubviews() {
        
    }
    
    public static func revealShapeSubviews() {
        
    }
}
