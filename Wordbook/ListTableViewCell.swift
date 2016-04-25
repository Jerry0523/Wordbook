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
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
