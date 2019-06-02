//
//  Toolbar.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/14/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit

class Toolbar: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    //Tool arrays for tools and shape options
    private final var toolArray: [UIImage] = [UIImage(named: "Move")!, UIImage(named: "ResizeSide")!, UIImage(named: "ResizeHorizontal")!, UIImage(named: "Circle")!, UIImage(named: "Rectangle")!, UIImage(named: "Pentagon")!, UIImage(named: "Star")!]
    private final var moreOptionsToolArray: [String] = ["Color"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (NewObjectConfigurationFromTable.newToolbarActivated) {
            self.tableView.selectRow(at: NewObjectConfigurationFromTable.toolSelected, animated: true, scrollPosition: .top)
        } else {
            self.tableView.selectRow(at: ArtCanvas.toolSelected, animated: true, scrollPosition: .top)
        }
        
        super.viewDidAppear(animated)
    }
    
    //Table view functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (NewObjectConfigurationFromTable.newToolbarActivated) {
            return moreOptionsToolArray.count
        } else {
            return toolArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
}
