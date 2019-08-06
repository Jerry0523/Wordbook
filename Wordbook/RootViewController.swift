//
//  ViewController.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class RootViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        primaryBackgroundStyle = .sidebar
        viewControllers = [
            UINavigationController(rootViewController: ListViewController()),
            WelcomeViewController()
        ]
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        if isCollapsed || vc.isKind(of: UINavigationController.self) {
            return false
        }
        showDetailViewController(UINavigationController(rootViewController: vc), sender: sender)
        return true
    }

}
