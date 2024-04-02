//
//  ListViewController.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 29.03.24.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    var viewModel = ListViewModel()
    let realm = RealmHelper.instance.realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTarget()
        configureVM()
        viewModel.getImageItems()
        tableView.registerNib(with: "PhotoCell")
    }
    
    fileprivate func setupView() {
        addButton.layer.cornerRadius = 8
    }
    fileprivate func setupTarget() {
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    @objc func addButtonAction() {
        print(#function)
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        vc.saveCb = { [weak self] in
            guard let self = self else {return}
            viewModel.getImageItems()
        }
        vc.modalPresentationStyle = .formSheet
               present(vc, animated: true)
    }
    fileprivate func reloadTable() {
        self.tableView.reloadData()
    }
    
    fileprivate func configureVM() {
        viewModel.successCallback = { [weak self] in
            guard let self = self else {return}
            reloadTable()
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeCell(cellClass: PhotoCell.self, indexPath: indexPath)
        let imageItems = viewModel.getList()
        let item = imageItems[indexPath.row]
        
        cell.descriptionLabel.text = item.desc
        let data = Data(base64Encoded: item.imageData)
        guard let data = data else {return cell}
        let image = UIImage(data: data)
        cell.photo.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
        
        func tableView(
            _ tableView: UITableView,
            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                let delete = UIContextualAction(
                    style: .destructive,
                    title: "Delete") { action, view, completionHandler in
                        self.viewModel.deleteItem(row: indexPath.row)
                    }
                
                let send = UIContextualAction(
                    style: .normal,
                    title: "Send") { action, view, completionHandler in
                        
                        //                    send description action
                    }
                
                let edit = UIContextualAction(
                    style: .normal,
                    title: "Edit") { action, view, completionHandler in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
                        vc.modalPresentationStyle = .formSheet
                        vc.currentRow = indexPath.row
                        var currentItem = self.viewModel.getList()[indexPath.row]
                        vc.defaultDesc = currentItem.desc
                        vc.updateCallback = { [weak self] (row, desc) in
                            self?.viewModel.editDesc(row: row, desc: desc)
                        }
                        self.present(vc, animated: true)
                    }
                
                return UISwipeActionsConfiguration(actions: [delete, send, edit])
            }
    }

