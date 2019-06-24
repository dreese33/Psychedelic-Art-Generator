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
    
    private var dimmingView: UIView!
    private var direction: PresentationDirection
    
    private func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?,
         direction: PresentationDirection) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        setupDimmingView()
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        
        //Clip dimming view to the ends of the screen
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView!]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView!]))
        
        //Sets alpha to 1.0 regardless of if transitionCoordinator exists
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    //Fit any changed to the container frame
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    //Restrict the toolbar to a certain amount of screen size (currently set at 2/3)
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch direction {
        case .left, .right:
            return CGSize(width: parentSize.width * (1.0 / 3.0), height: parentSize.height)
        case .top, .bottom:
            return CGSize(width: parentSize.width, height: parentSize.height * (1.0 / 3.0))
        }
    }
    
    //Resize the frame of presenting view controller
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)
        
        switch direction {
        case .right:
            frame.origin.x = containerView!.frame.width * (1.0 / 3.0)
        case .bottom:
            frame.origin.y = containerView!.frame.height * (1.0 / 3.0)
        default:
            frame.origin = .zero
        }
        
        return frame
    }
}
