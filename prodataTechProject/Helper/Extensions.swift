//
//  Extensions.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 29.03.24.
//

import Foundation
import UIKit
import SDWebImage

extension UITableView {
    func registerNib(with identifier: String)
    {
        self.register(UINib(nibName: identifier, bundle: Bundle.main), forCellReuseIdentifier: identifier)
    }
    func registerCodedCell(with cellClass: AnyClass)
    {
        let identifier = String(describing: cellClass.self)
        self.register(cellClass, forCellReuseIdentifier: identifier)
    }
    func dequeCell<T>(cellClass : T.Type, indexPath: IndexPath) -> T where T: UITableViewCell
    {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
}

extension UIImageView {
    func loadURL(_ url: String) {
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: urlString) {
            sd_setImage(with: url)
        }
    }
}
