//
//  WordListController.swift
//  Wordbook
//
//  Created by 王杰 on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit
import CoreData
import JWRefreshControl

class ListViewController: UITableViewController {

    let cellIdentifier = "cellIdentifier"
    var notes: [NoteModel]?
    
    func reloadData() {
        print("refreshing")
        self.notes = NoteEntity.getNotes()
        self.tableView.reloadData()
    }
    
    @objc func didReceiveDataChangeNotification(_ notification: NSNotification) {
        if self.isViewLoaded && self.view.window == nil {
            self.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addRefreshHeader { [unowned self] header in
            self.reloadData()
            header.success()
        }
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 95
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.didReceiveDataChangeNotification(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.notes == nil {
            return 0
        }
        return self.notes!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ListTableViewCell
        let note = self.notes![indexPath.row]
        
        cell.word?.text = note.title
        cell.definition?.text = note.definition
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = self.notes![indexPath.row]
        let vc = SearchViewController()
        vc.noteModel = note
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
                let noteModel = self.notes![indexPath.row]
                NoteEntity.deleteNote(noteModel)
                self.notes?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                handler(true)
            }
        ])
    }
    
}
