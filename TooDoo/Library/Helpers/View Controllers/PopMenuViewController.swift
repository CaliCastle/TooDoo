//
//  PopMenuViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 4/12/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit

final public class PopMenuManager: NSObject {
    
    public static let shared = PopMenuManager()
    
    private var popMenu: PopMenuViewController!
    
    private func prepareViewController() {
        popMenu = PopMenuViewController()
    }
    
    public func present(above: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        prepareViewController()
        
        guard let popMenu = popMenu else { print("Pop Menu has not been initialized yet."); return }
        
        popMenu.modalPresentationCapturesStatusBarAppearance = true
        
        if let presentOn = above {
            presentOn.present(popMenu, animated: animated, completion: completion)
        } else {
            if let topViewController = ApplicationManager.getTopViewControllerInWindow() {
                topViewController.present(popMenu, animated: animated, completion: completion)
            }
        }
    }
    
}

final public class PopMenuViewController: UIViewController {
    
    // MARK: - Initializers
    
    required public init() {
        super.init(nibName:nil, bundle:nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been supported")
    }
    
    // MARK: - View Configuration
    
    public override func loadView() {
        super.loadView()
        
        view.frame = UIScreen.main.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
