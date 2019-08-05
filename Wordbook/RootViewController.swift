//
//  ViewController.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UISearchBarDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = self.searchBar
        view.addSubview(self.listVC.view)
        addChild(self.listVC)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let word = searchBar.text!
        if word.count == 0 {
            return
        }
        searchBar.text = nil
        searchBar.resignFirstResponder()
        
        let vc = SearchViewController()
        vc.word = word
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Lazy Properties
    lazy var listVC: ListViewController = {
        let vc = ListViewController()
        vc.view.frame = self.view.bounds
        return vc
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Enter a word"
        searchBar.delegate = self
        return searchBar
    }()
}

