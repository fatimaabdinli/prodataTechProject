//
//  RealmHelper.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 01.04.24.
//

import Foundation
import RealmSwift

class RealmHelper {
    typealias Transaction = () -> Void
    
    public static let instance = RealmHelper()
    let realm = try! Realm()
    
    private init() {}
    
    func saveObjectToRealm(object: Object, update: Bool = true) {
        openTransaction {
            if update {
                realm.add(object, update: .modified)
            } else {
                realm.add(object)
            }
        }
    }
    
    func openTransaction(transaction: Transaction) {
        try? realm.safeWrite {
            transaction()
        }
    }
    
    func deleteRealm()  {
        try? realm.write{
            realm.deleteAll()
        }
    }
    
    func getFileUrl() -> URL {
        return (realm.configuration.fileURL)!
    }
}

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
