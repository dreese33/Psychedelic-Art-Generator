//
//  ShiftScreenPresentationController.swift
//  Psychedelic Art Generator
//
//  Created by Eric Reese on 6/10/19.
//  Copyright © 2019 ReeseGames. All rights reserved.
//

import Foundation
import UIKit

//Presentation controller for moving screen
final class ShiftScreenPresentationController: UIPresentationController {
    
    private let presentedXOffset: CGFloat = 74
    
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }
        
        let view = UIView(frame: container.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        )
        
        return view
    }()
    
    //Unused
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    @objc func didTap(tap: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        return CGRect(x: 0, y: 0, width: self.presentedXOffset, height: container.bounds.height)
    }
    
    
    override func presentationTransitionWillBegin() {
        guard let container = containerView else { return }
        
        //dimmingView.alpha = 0
        //container.bounds.origin.x = -presentedXOffset
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)
        //self.presentedView!.superview!.superview!.superview!.bounds.origin.x = -presentedXOffset
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let `self` = self else { return }
            
            self.dimmingView.alpha = 0
            //self.dimmingView.superview!.superview!.bounds.origin.x = 0
            }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
     }
}
