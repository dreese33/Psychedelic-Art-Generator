//
//  ShiftScreenTransitioningDelegate.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 6/10/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import Foundation
import UIKit

//The direction in which to present the controller
enum PresentationDirection {
    case left
    case top
    case right
    case bottom
}

//Transitioning Delegate for shifting screen from click
final class ShiftScreenTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactiveDismiss = true
    var direction = PresentationDirection.left
    
    init(from presented: UIViewController, to presenting: UIViewController) {
        super.init()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShiftScreenPresentationAnimator(direction: .left, isPresentation: false)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShiftScreenPresentationAnimator(direction: .left, isPresentation: true)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ShiftScreenPresentationController(presentedViewController: presented, presenting: presenting, direction: .left)
    }
}
