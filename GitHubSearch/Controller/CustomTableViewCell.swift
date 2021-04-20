//
//  CustomTableViewCell.swift
//  GitHubSearch
//
//  Created by Dhruvil Patel on 4/20/21.
//  Copyright © 2021 Dhruvil Patel. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var rightImageArrow: UIImageView!
    private var task: URLSessionDataTask?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImageView.image = nil
        task?.cancel()
        task = nil
        userImageView.image = nil
    }
    func configureWith(urlString: String,saveAsCache:Bool) {
        if task == nil {
            // Ignore calls when reloading
            task = userImageView.downloadImage(from: urlString, saveAsCache: saveAsCache)
        }
    }
    
}
