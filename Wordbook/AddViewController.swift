//
//  ViewController.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UISearchBarDelegate{
    
    var label :UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter a word"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        label = UILabel(frame: CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        self.view.addSubview(label!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadData() {
        let notes = Note.getNotes(nil)
        
        let mutableString = NSMutableString()
        for note in notes! {
            mutableString.appendFormat("%@:%@\n", note.title!, note.definition!)
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let word = searchBar.text!
        if word.characters.count == 0 {
            return
        }
        
        let notes = Note.getNotes(word)
        if notes?.count > 0 {
            
        } else {
            NetworkManager.sharedInstance.requestWordTranslation(word) { (item :AnyObject?, error :NSError?) in
                if error == nil && item != nil {
                    let itemDict = item as! Dictionary<String, AnyObject>
                    let translationsArray = itemDict["trans_result"] as! Array<Dictionary<String, String>>
                    if translationsArray.count > 0 {
                        let translationDict = translationsArray[0]
                        let translatedValue = translationDict["dst"]
                        if translatedValue?.characters.count > 0 {
                            Note.addNote(word, definition: translatedValue!)
                            self.reloadData()
                        }
                    }
                }
            }
        }
    }
}

