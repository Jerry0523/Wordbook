//
//  WordListController.swift
//  Wordbook
//
//  Created by 王杰 on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class WordListController: UITableViewController {

    var notes :[Note]?
    let cellIdentifier = "cellIdentifier"
    
    func reloadData() {
        self.notes = Note.getNotes(nil)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.notes == nil {
            return 0
        }
        return self.notes!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let note = self.notes![indexPath.row]
        
        cell!.textLabel?.text = note.title
        cell!.detailTextLabel?.text = note.definition
        
        return cell!
    }

}
