//
//  TableViewCell.swift
//  trans_addr
//
//  Created by L703 on 2016. 11. 2..
//  Copyright © 2016년 dit201212711. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var ZipNo: UILabel!
    @IBOutlet weak var LnmAdres: UILabel!
    @IBOutlet weak var RnAdres: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
