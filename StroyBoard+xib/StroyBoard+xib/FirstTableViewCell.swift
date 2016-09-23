//
//  FirstTableViewCell.swift
//  StroyBoard+xib
//
//  Created by zhangnian on 16/9/23.
//  Copyright © 2016年 zhangnian. All rights reserved.
//

import UIKit

class FirstTableViewCell: UITableViewCell {

    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var cellSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
