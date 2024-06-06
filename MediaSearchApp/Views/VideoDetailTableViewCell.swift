//
//  VideoDetailTableViewCell.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/2/24.
//

import UIKit

class VideoDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
