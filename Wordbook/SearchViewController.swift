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
            noteModel?.checkAndDownloadSoundFile() { [unowned self] in
                if self.isViewLoaded {
                    self.audioButton.isHidden = self.noteModel?.audioData == nil
                }
                self.audioButtonClicked(sender: nil)
            }
            
            if self.isViewLoaded && noteModel != nil {
                self.refreshUIByNote()
            }
        }
    }
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var pronunciationLabel: UILabel!
    @IBOutlet weak var cnDefinitionsLabel: UILabel!
    @IBOutlet weak var enDefinitionsLabel: UILabel!
    
    @IBAction func audioButtonClicked(sender: AnyObject?) {
        do {
            self.player = try AVAudioPlayer(data: (self.noteModel?.audioData)! as Data)
            self.player!.play()
        } catch {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.noteModel != nil {
            self.refreshUIByNote()
            self.loadingView.stopAnimating()
        } else {
            self.contentView.isHidden = true
            self.loadingView.startAnimating()
            self.searchWord(word: self.word!)
            
            let addItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(SearchViewController.didAddToWordBook(_:)))
            self.navigationItem.rightBarButtonItem = addItem
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func didAddToWordBook(_ sender: AnyObject?) {
        if self.noteModel != nil {
            NoteEntity.insert(note: self.noteModel!)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func searchWord(word: String) {
        self.loadingView.startAnimating()
        if let notes = NoteEntity.getNotes(word), notes.count > 0 {
            self.noteModel = notes.first!
        } else {
            self.requestWordTranslation(word)
        }
    }
    
    private func requestWordTranslation(_ word :String) {
        NetworkManager.shared.requestShanbeiTranslate(word) {[weak self] (item :NoteModel?, error :Error?) in
            if error != nil || item == nil {
                print((error?.localizedDescription)!)
            } else {
                self?.noteModel = item
            }
        }
    }
    
    private func refreshUIByNote() {
        guard let noteModel = noteModel else {
            return
        }
        titleLabel.text = noteModel.title
        let pronunciationText: String! = noteModel.pronunciation == nil ? "" : noteModel.pronunciation
        pronunciationLabel.text = "[" + pronunciationText + "]"
        cnDefinitionsLabel.text = noteModel.definition
        enDefinitionsLabel.text = noteModel.getEnDefinitionString()
        audioButton.isHidden = noteModel.audioData == nil
        contentView.isHidden = false
        loadingView.stopAnimating()
    }
}
