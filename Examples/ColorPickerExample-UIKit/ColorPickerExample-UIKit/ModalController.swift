//
//  ModalController.swift
//  ColorPickerExample-UIKit
//
//  Created by Šimon Strýček on 04.04.2022.
//

import UIKit

//
// Převzato z: https://medium.com/@vialyx/import-uikit-custom-modal-transitioning-with-swift-6f320de70f55
//

class BlurModalController: UIPresentationController {
    private lazy var blurView: UIView! = {
        guard let container = containerView
        else {
            return nil
        }
        
        let view = UIView(frame: container.bounds)
        view.backgroundColor = .black.withAlphaComponent(0.75)
        
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        guard
            let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator
        else {
            return
        }
        
        container.alpha = 1
        container.addSubview(blurView)
        blurView.addSubview(presentedViewController.view)
        
        coordinator.animate { [weak self] context in
            guard let `self` = self
            else {
                return
            }
            
            self.blurView.alpha = 1
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard
            let coordinator = presentingViewController.transitionCoordinator
        else {
            return
        }
        
        coordinator.animate { [weak self] (context) -> Void in
            guard let `self` = self
            else {
                return
            }
            
            self.blurView.alpha = 1
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        blurView.removeFromSuperview()
    }
}

final class BlurModalDelegate: NSObject, UIViewControllerTransitioningDelegate {
    init(from presented: UIViewController, to presenting: UIViewController) {
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BlurModalController(presentedViewController: presented, presenting: presenting)
    }
}

//
//
//
