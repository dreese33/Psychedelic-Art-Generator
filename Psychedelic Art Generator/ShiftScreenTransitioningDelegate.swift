//
//  ShiftScreenTransitioningDelegate.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 6/10/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import Foundation
import UIKit

//Transitioning Delegate for shifting screen from click
final class ShiftScreenTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactiveDismiss = true
    
    init(from presented: UIViewController, to presenting: UIViewController) {
        super.init()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ShiftScreenPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
