//
//  WordListController.swift
//  Wordbook
//
//  Created by 王杰 on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit
import CoreData
import Combine
import JWRefreshControl

class ListViewController: UITableViewController {

    let cellIdentifier = "cellIdentifier"
    
    var notes: [NoteModel]?
    
    var selectedCategory: CategoryModel? {
        didSet {
            reloadData()
        }
    }
    
    func reloadData(with header: RefreshHeaderControl<DefaultRefreshHeaderContentView>? = nil) {
        print("refreshing")
        let filters: [NoteEntity.NoteFilter]?
        if let selectedCategory = selectedCategory {
            filters = [.category(code: selectedCategory.code)]
        } else {
            filters = nil
        }
        notes = NoteEntity.getNotes(filters)
        tableView.reloadData()
        header?.success()
    }
    
    func loadMore(with footer: RefreshFooterControl<DefaultRefreshFooterContentView>? = nil) {
        guard let notes = notes else {
            fatalError()
        }
        let offset = notes.count
        if let moreData = NoteEntity.getNotes(nil, offset: offset), moreData.count > 0 {
            self.notes?.append(contentsOf: moreData)
            tableView.insertRows(at: moreData.enumerated().map {
                IndexPath(row: $0.offset + offset, section: 0)
            }, with: .automatic)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            footer?.success()
        } else {
            footer?.pause("No More Data")
        }
    }
    
    func clearSelectionIfNeeded() {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    @objc func didClickCategoryBtn(sender: UIButton) {
        self.showActionSheet("Select a category") { [unowned self] controller in
            if let popover = controller.popoverPresentationController {
                popover.sourceView = sender
                popover.permittedArrowDirections = .right
            }
            controller.addAction(UIAlertAction(title: "[ All ]", style: (self.selectedCategory == nil ? .destructive : .default)) { [unowned self] _ in
                self.categoryBtn.setImage(UIImage(named: "category"), for: .normal)
                self.categoryBtn.setTitle(nil, for: .normal)
                self.selectedCategory = nil
            })
            controller.addAction(UIAlertAction(title: "[ Not Set ]", style: (self.selectedCategory?.code == 0 ? .destructive : .default)) { [unowned self] _ in
                self.categoryBtn.setImage(nil, for: .normal)
                self.categoryBtn.setTitle("NA", for: .normal)
                self.selectedCategory = CategoryModel(name: "NA", code: 0)
            })
            CategoryEntity.getCategories()?.map { category in
                let name = category.name
                let style: UIAlertAction.Style = self.selectedCategory.map { $0.code == category.code }.map { $0 ? .destructive : .default } ?? .default
                return UIAlertAction(title: name, style: style) { [unowned self] action in
                    self.categoryBtn.setImage(nil, for: .normal)
                    self.categoryBtn.setTitle(String(name.prefix(1)).uppercased(), for: .normal)
                    self.selectedCategory = category
                }
            }.forEach {
                controller.addAction($0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryBtn.addTarget(self, action: #selector(didClickCategoryBtn(sender:)), for: .touchUpInside)
        navigationController?.view.addSubview(categoryBtn)
        categoryBtn.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        categoryBtn.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        categoryBtn.rightAnchor.constraint(equalTo: categoryBtn.superview!.rightAnchor, constant: -20).isActive = true
        categoryBtn.bottomAnchor.constraint(equalTo: categoryBtn.superview!.bottomAnchor, constant: -20).isActive = true
        
        navigationItem.titleView = searchBar
        clearsSelectionOnViewWillAppear = true
        
        tableView.addRefreshHeader { [unowned self] header in
            self.reloadData(with: header)
        }
        
        tableView.addRefreshFooter { [unowned self] footer in
            self.loadMore(with: footer)
        }
        
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 95
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        reloadData()
        
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
        cell.update(with: note)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = self.notes![indexPath.row]
        let vc = SearchViewController()
        vc.noteModel = note
        splitViewController?.showDetailViewController(vc, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            {
                let action = UIContextualAction(style: .normal, title: "Classify") { [unowned self] _, _, handler in
                    self.requestClassify(at: indexPath, handler: handler)
                }
                action.backgroundColor = UIColor(named: "vivid")
                return action
            }()
        ])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            {
                let action = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, handler in
                    self.requestDelete(at: indexPath, handler: handler)
                }
                action.backgroundColor = UIColor(named: "theme")
                return action
            }()
        ])
    }
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Enter a word"
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var categoryBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "category"), for: .normal)
        btn.setTitleColor(UIColor(named: "theme"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.backgroundColor = UIColor(named: "background.main")
        btn.layer.cornerRadius = 30.0
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(named: "background.sub")?.cgColor
        btn.layer.masksToBounds = true
        return btn
    }()
    
    var operationStore = Set<AnyCancellable>()
    
}

extension ListViewController {
    
    private func requestClassify(at indexPath: IndexPath, handler: @escaping (Bool) -> Void) {
        let noteModel = self.notes![indexPath.row]
        self.showActionSheet("Assign \"\(noteModel.title ?? "")\" to a category") { [unowned self] controller in
            if let popover = controller.popoverPresentationController {
                popover.sourceView = self.tableView.cellForRow(at: indexPath)!
                popover.permittedArrowDirections = .any
            }
            controller.addAction(UIAlertAction(title: "[ Add a new category ]", style: .default) { [unowned self] action in
                self.showInput("Create a new category", placeHolder: "Category Name")
                .flatMap { CategoryEntity.newCategory(for: $0) }
                .map { category in
                    NoteEntity.update(note: noteModel) {
                        $0.category_code = category.code
                    }
                    self.reloadData()
                }
                .replaceError(with: ())
                .sink{
                    handler(true)
                }
                .store(in: &self.operationStore)
            })
            CategoryEntity.getCategories()?.map { category in
                UIAlertAction(title: category.name, style: category.code == noteModel.categoryCode ? .destructive : .default) { [unowned self] action in
                    NoteEntity.update(note: noteModel) {
                        $0.category_code = category.code
                    }
                    handler(true)
                    self.reloadData()
                }
            }.forEach {
                controller.addAction($0)
            }
        }
    }
    
    private func requestDelete(at indexPath: IndexPath, handler: @escaping (Bool) -> Void) {
        let noteModel = notes![indexPath.row]
        showConfirm("Do you want to delete \"\(noteModel.title ?? "")\"").sink { [unowned self] confirm in
            if confirm {
                NoteEntity.deleteNote(noteModel)
                self.notes?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            handler(confirm)
        }.store(in: &operationStore)
    }
    
    private func showAlert(_ msg: String, preferredStyle: UIAlertController.Style, config: (UIAlertController) -> ()) {
        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: preferredStyle)
        config(alertController)
        present(alertController, animated: true)
    }
    
    private func showInput(_ msg: String, placeHolder: String) -> AnyPublisher<String, Error> {
        return Future { [unowned self] promise in
            self.showAlert(msg, preferredStyle: .alert) { controller in
                controller.addTextField {
                    $0.placeholder = placeHolder
                }
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                    promise(.failure(NSError()))
                })
                controller.addAction(UIAlertAction(title: "OK", style: .default) { [unowned controller] action in
                    if let name = controller.textFields?.first?.text {
                        promise(.success(name))
                    } else {
                        promise(.failure(NSError()))
                    }
                })
            }
        }.eraseToAnyPublisher()
    }
    
    private func showConfirm(_ msg: String) -> AnyPublisher<Bool, Never> {
        return Future { [unowned self] promise in
            self.showAlert(msg, preferredStyle: .alert) {
                $0.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                    promise(.success(false))
                })
                $0.addAction(UIAlertAction(title: "OK", style: .default) { action in
                    promise(.success(true))
                })
            }
        }.eraseToAnyPublisher()
    }
    
    private func showActionSheet(_ msg: String, config: (UIAlertController) -> ()) {
        showAlert(msg, preferredStyle: .actionSheet, config: config)
    }
    
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
