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
    
    func clearSelectionIfNeeded() {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        clearsSelectionOnViewWillAppear = true
        
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
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil, queue: nil) { [weak self] note in
//            self?.reloadDataIfNeeded()
//        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(listDidChangeNotification), object: nil, queue: nil) { [weak self] note in
            self?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let note = self.notes![indexPath.row]
        let vc = SearchViewController()
        vc.noteModel = note
        splitViewController?.showDetailViewController(vc, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "Delete") { [unowned self] action, view, handler in
                let noteModel = self.notes![indexPath.row]
                NoteEntity.deleteNote(noteModel)
                self.notes?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                handler(true)
            }
        ])
    }
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Enter a word"
        searchBar.delegate = self
        return searchBar
    }()
    
}

extension ListViewController : UISearchBarDelegate {
    
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
            splitViewController?.showDetailViewController(vc, sender: nil)
            clearSelectionIfNeeded()
        }
    
}
