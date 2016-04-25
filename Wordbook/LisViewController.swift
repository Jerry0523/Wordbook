//
//  WordListController.swift
//  Wordbook
//
//  Created by 王杰 on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {

    let cellIdentifier = "cellIdentifier"
    var notes: [NoteModel]?
    
    lazy var headerView: JWRefreshHeaderView = {
        let refreshHeader = JWRefreshHeaderView.headerWithRefreshingBlock {
            [weak self] in
            self?.reloadData()
            (self?.headerView.contentView as! JWRefreshContentViewProtocol).loadedSuccess!()
            self?.headerView.endRefreshingWithDelay(1.0)
        }
        refreshHeader.tintColor = AppConst.themeColor
        return refreshHeader
    }()
    
    func reloadData() {
        NSLog("refreshing")
        self.notes = Note.getNotes(nil)
        self.tableView.reloadData()
    }
    
    func didReceiveDataChangeNotification(notification: NSNotification) {
        if self.isViewLoaded() && self.view.window == nil {
            self.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.headerView)
        self.tableView.registerNib(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableView.estimatedRowHeight = 95
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.reloadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ListViewController.didReceiveDataChangeNotification(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ListTableViewCell
        let note = self.notes![indexPath.row]
        
        cell.word?.text = note.title
        cell.definition?.text = note.definition
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let note = self.notes![indexPath.row]
        let vc = SearchViewController()
        vc.noteModel = note
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { [weak self] (action, indexPath) -> Void in
            let noteModel = self?.notes![indexPath.row]
            Note.deleteNote(noteModel!)
            self?.notes?.removeAtIndex(indexPath.row)
            self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        deleteAction.backgroundColor = AppConst.themeColor
        
        let classifyAction = UITableViewRowAction(style: .Default, title: "Classify") { [weak self] (action, indexPath) -> Void in
//            let noteModel = self?.notes![indexPath.row]
//            Note.deleteNote(noteModel!)
//            self?.notes?.removeAtIndex(indexPath.row)
//            self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        classifyAction.backgroundColor = UIColor.init(red: 67.0 / 255.0, green: 176.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0)
        
        return [classifyAction, deleteAction]
    }

}
