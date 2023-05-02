//
//  AddMemberTableViewCell.swift
//  FairTask
//
//  Created by Na Tian on 2/5/2023.
//

import UIKit

protocol AddMemberDelegate: AnyObject {
    func addNewMember(_ newMember: String)
}

class AddMemberTableViewCell: UITableViewCell, UITextFieldDelegate {
    static let identifier = "AddMemberTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "AddMemberTableViewCell", bundle: nil)
    }
    weak var delegate: AddMemberDelegate?
    
    @IBOutlet weak var plusIcon: UIImageView!
    @IBOutlet weak var newMemberTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        newMemberTextField.delegate = self
        newMemberTextField.placeholder = "Add new member"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addMember(_ sender: Any) {
        if let newMember = newMemberTextField.text, !newMember.isEmpty {
            delegate?.addNewMember(newMember)
            newMemberTextField.text = nil
        }
    }
    
}
