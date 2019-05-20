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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NewObjectConfigurationFromTable.newToolbarActivated = true
        self.view.backgroundColor = UIColor.white
    }
    
    //Popover presentation enabled
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
