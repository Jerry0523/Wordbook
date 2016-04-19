//
//  ViewController.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UISearchBarDelegate{
    
    lazy var listVC :WordListController = WordListController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter a word"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        self.addChildViewController(self.listVC)
        self.listVC.view.frame = self.view.bounds
        self.view.addSubview(self.listVC.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestWordTranslation(word :String) {
        NetworkManager.sharedInstance.requestWordTranslation(word) {[weak self] (item :AnyObject?, error :NSError?) in
            if error == nil && item != nil {
                let itemDict = item as! Dictionary<String, AnyObject>
                let translationsArray = itemDict["trans_result"] as! Array<Dictionary<String, String>>
                if translationsArray.count > 0 {
                    let translationDict = translationsArray[0]
                    let translatedValue = translationDict["dst"]
                    if translatedValue?.characters.count > 0 {
                        Note.addNote(word, definition: translatedValue!)
                        self?.listVC.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let word = searchBar.text!
        if word.characters.count == 0 {
            return
        }
        
        searchBar.resignFirstResponder()
        
        let notes = Note.getNotes(word)
        if notes?.count > 0 {
            
        } else {
           self.requestWordTranslation(word)
        }
    }
}

