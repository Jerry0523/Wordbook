//
//  ListTableViewCell.swift
//  Wordbook
//
//  Created by Jerry on 16/4/21.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var definition: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            selectedBackgroundView?.backgroundColor = UIColor(named: "theme")
            word.textColor = UIColor.white
            definition.textColor = UIColor.white
        } else {
            selectedBackgroundView?.backgroundColor = UIColor.white
            word.textColor = UIColor(named: "theme")
            definition.textColor = UIColor(named: "text.sub")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setHighlighted(selected, animated: animated)
    }
    
    func update(with note: NoteModel) {
        word?.text = note.title
        definition?.text = note.definition
    }
    
}
