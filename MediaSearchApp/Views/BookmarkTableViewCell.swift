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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookmarkImageView.image = nil
        bookmarkNameLabel.text = ""
    }
    
}
