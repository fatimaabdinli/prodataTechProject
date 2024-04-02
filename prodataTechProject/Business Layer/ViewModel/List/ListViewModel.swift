//
//  ListViewModel.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 29.03.24.
//

import Foundation
import RealmSwift

class ListViewModel {
    private var imageList: Results<ImageItem>?
    let realm = RealmHelper.instance.realm
    var successCallback: (() -> Void)?
    
    func getImageItems() {
        let results = realm.objects(ImageItem.self)
        imageList = results
        successCallback?()
    }
    
    func getList() -> Results<ImageItem> {
        return imageList!
    }
    
    func getCount() -> Int {
        return imageList!.count
    }
    
    func deleteItem(row: Int) {
        if (!imageList!.isEmpty) {
            let currentImage = imageList![row]
            try! realm.write {
                realm.delete(currentImage ?? ImageItem())
                self.getImageItems()
            }
        }
    }
    
    func editDesc(row: Int, desc: String) {
        let item = imageList![row]
        try! realm.write {
            item.desc = desc
        }
        getImageItems()
    }
}

