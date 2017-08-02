//
//  AddTextFieldTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/12.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class AddTextFieldTableViewCell: UITableViewCell{

    @IBOutlet weak var titleLabel: UILabel!
     @IBOutlet weak var rightTextField: UITextField!
    override func awakeFromNib() {
       
        super.awakeFromNib()
        // Initialization code
        rightTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
extension AddTextFieldTableViewCell: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        rightTextField.resignFirstResponder()
        return true
    }
}
