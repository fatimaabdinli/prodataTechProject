//
//  ListViewController.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 29.03.24.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class ListViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    var imageItems: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTarget()
        getImageItems()
        tableView.registerNib(with: "PhotoCell")
    }
    
    fileprivate func setupTarget() {
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    @objc func addButtonAction() {
        print(#function)
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        vc.saveCb = getImageItems
        vc.modalPresentationStyle = .formSheet
               present(vc, animated: true)
    }
    
    fileprivate func getImageItems() {
        self.imageItems.removeAll()
        self.tableView.reloadData()
        
        let db = Firestore.firestore()
        db.collection("imageItems").getDocuments(completion: { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            print(snapshot.documents)
//            for doc in snapshot.documents {
//                self.imageItems.append(["imageName": doc["imageName"] as! String, "description": doc["description"] as! String])
//            }
//            self.tableView.reloadData()
        })
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imageItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeCell(cellClass: PhotoCell.self, indexPath: indexPath)
        let item = imageItems[indexPath.row]
        cell.descriptionLabel.text = item["description"]
        cell.imageName = item["imageName"]
        
        let storageRef = Storage.storage().reference()
        let file = storageRef.child(item["imageName"] as! String)
        file.getData(maxSize: 10 * 1024 * 1024, completion: { [weak self] (data, error) in
            guard let data = data else {return}
            
            let image = UIImage(data: data)
            cell.photo.image = image
            cell.descriptionLabel.text = item["description"]
        })
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(
                style: .destructive,
                title: "Delete") { action, view, completionHandler in
//                    delete action
//                    self.deleteObject(index: indexPath.row)
                }
            
            let send = UIContextualAction(
                style: .normal,
                title: "Send") { action, view, completionHandler in
//                    edit description action
                }
            
            let edit = UIContextualAction(
                style: .normal,
                title: "Edit") { action, view, completionHandler in
//                    send description action
                }
            
            return UISwipeActionsConfiguration(actions: [delete, send, edit])
        }
}
