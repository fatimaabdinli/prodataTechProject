//
//  ImageItem.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 01.04.24.
//

import Foundation
import RealmSwift

class ImageItem: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var desc: String
    @Persisted var imageData: String
}
