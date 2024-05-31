//
//  ImageDetailTableViewCell.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/29/24.
//

import UIKit

class ImageDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
