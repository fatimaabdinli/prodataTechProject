//
//  PhotoCell.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 31.03.24.
//

import UIKit
import FirebaseStorage

class PhotoCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var imageName: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let storageRef = Storage.storage().reference()
//        guard let imageName = imageName else {return}
//        
//        let file = storageRef.child(imageName)
//        file.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
//            guard let data = data else {return}
//            
//            let image = UIImage(data: data)
//            self.photo.image = image
//        })
    }
}

