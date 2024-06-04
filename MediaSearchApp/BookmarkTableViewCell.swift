//
//  BookmarkTableViewCell.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/3/24.
//

import UIKit

class BookmarkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookmarkImageView: UIImageView!
    @IBOutlet weak var bookmarkNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
