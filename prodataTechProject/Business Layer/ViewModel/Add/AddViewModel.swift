//
//  AddViewModel.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 30.03.24.
//

import Foundation
import UIKit
import RealmSwift

class AddViewModel {
    let realm = RealmHelper.instance.realm
    
    func saveObjectToRealm(image: UIImage, desc: String) {
        let imageItem = ImageItem()
        let data = image.jpegData(compressionQuality: 0.8)
        guard let data = data else {return}
        imageItem.imageData = NSData(data: data).base64EncodedString()
        imageItem.desc = desc
        
        try! realm.write() {
            realm.add(imageItem)
        }
    }
}
