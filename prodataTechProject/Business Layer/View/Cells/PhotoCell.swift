//
//  PhotoCell.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 31.03.24.
//

import UIKit


protocol ImageProtocol {
    var name: String {get}
    var image: UIImage {get}
}

class PhotoCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
 
    }
}

