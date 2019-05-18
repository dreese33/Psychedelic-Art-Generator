//
//  Toolbar.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 5/14/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import UIKit

class Toolbar: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    private final var toolArray: [UIImage] = [UIImage(named: "Circle")!, UIImage(named: "Rectangle")!, UIImage(named: "Pentagon")!, UIImage(named: "Star")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.selectRow(at: ArtCanvas.toolSelected, animated: true, scrollPosition: .top)
        super.viewDidAppear(animated)
    }
    
    //Table view functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toolArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toolCell")
        cell!.imageView!.center = cell!.center
        cell!.imageView!.image = toolArray[indexPath.row]
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Set IndexPath for ArtCanvas class
        ArtCanvas.toolSelected = indexPath
    }
    
    //Popover presentation capabilities
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
