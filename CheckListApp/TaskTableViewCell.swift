//
//  TaskTableViewCell.swift
//  CheckListApp
//
//  Created by Anton Kolesnikov on 25.11.2022.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    var task: Task?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        doneButton.setImage(UIImage(systemName: "circle"), for: .normal)
        doneButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
