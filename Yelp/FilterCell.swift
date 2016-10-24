//
//  FilterCell.swift
//  Yelp
//
//  Created by Keith Lee on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterCellDelegate: class {
    @objc optional func filterCell(filterCell: FilterCell, switchChangedValue newValue: Bool)
}

class FilterCell: UITableViewCell {

    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    
    weak var delegate: FilterCellDelegate?
    
    var expandable: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        accessoryType = .checkmark
//        filterSwitch.isHidden = true
    }

    @IBAction func switchValueChange(_ sender: UISwitch) {
        delegate?.filterCell?(filterCell: self, switchChangedValue: filterSwitch.isOn)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
