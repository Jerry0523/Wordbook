//
//  SearchResultViewController.swift
//  Wordbook
//
//  Created by Jerry on 16/4/20.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit
import AVFoundation

class SearchViewController: UIViewController {
    
    var word: String?
    var noteModel: NoteModel? {
        didSet {
            noteModel?.checkAndDownloadSoundFile({ [weak self] in
                self?.audioButton.hidden = self?.noteModel?.audioData == nil
                self?.audioButtonClicked(nil)
            })
            
            if self.isViewLoaded() && noteModel != nil {
                self.refreshUIByNote()
            }
        }
    }
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: JWDotLoadingView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var pronunciationLabel: UILabel!
    @IBOutlet weak var cnDefinitionsLabel: UILabel!
    @IBOutlet weak var enDefinitionsLabel: UILabel!
    
    @IBAction func audioButtonClicked(sender: AnyObject?) {
        do {
            self.player = try AVAudioPlayer(data: (self.noteModel?.audioData)!)
            self.player!.play()
            
        } catch {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.noteModel != nil {
            self.refreshUIByNote()
            self.loadingView.stopAnimating()
        } else {
            self.contentView.hidden = true
            self.loadingView.startAnimating()
            self.searchWord(self.word!)
            
            let addItem = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: #selector(SearchViewController.didAddToWordBook(_:)))
            self.navigationItem.rightBarButtonItem = addItem
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didAddToWordBook(sender: AnyObject?) {
        if self.noteModel != nil {
            Note.insertNote(self.noteModel!)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func searchWord(word: String) {
        self.loadingView.startAnimating()
        let notes = Note.getNotes(word)
        if notes?.count > 0 {
            self.noteModel = notes![0]
        } else {
            self.requestWordTranslation(word)
        }
    }
    
    private func requestWordTranslation(word :String) {
        NetworkManager.sharedInstance.requestShanbeiTranslate(word) {[weak self] (item :NoteModel?, error :NSError?) in
            if error != nil || item == nil {
                NSLog((error?.localizedDescription)!)
            } else {
                self?.noteModel = item
            }
        }
    }
    
    private func refreshUIByNote() {
        if self.noteModel != nil {
            titleLabel.text = noteModel?.title
            let pronunciationText: String! = noteModel?.pronunciation == nil ? "" : noteModel?.pronunciation
            pronunciationLabel.text = "[" + pronunciationText + "]"
            cnDefinitionsLabel.text = noteModel?.definition
            enDefinitionsLabel.text = noteModel?.getEnDefinitionString()
            
            audioButton.hidden = noteModel?.audioData == nil
            
            contentView.hidden = false
            loadingView.stopAnimating()
            
        } else {
            
        }
    }
}
