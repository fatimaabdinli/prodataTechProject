//
//  ListViewController.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 29.03.24.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTarget()
        tableView.registerNib(with: "PhotoCell")
    }
    
    fileprivate func setupTarget() {
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    @objc func addButtonAction() {
        print(#function)
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        vc.modalPresentationStyle = .formSheet
               present(vc, animated: true)
             
    }
    
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeCell(cellClass: PhotoCell.self, indexPath: indexPath)
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
            let edit = UIContextualAction(
                style: .normal,
                title: "Edit") { action, view, completionHandler in
//                    edit description action
                }
            return UISwipeActionsConfiguration(actions: [delete, edit])
        }
}
