//
//  ListViewController.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 29.03.24.
//

import UIKit
import RealmSwift
import MessageUI

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
    }
    
    fileprivate func setupView() {
        tableView.registerNib(with: "PhotoCell")
        addButton.layer.cornerRadius = 8
        tableView.allowsSelection = false
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
    
    fileprivate func sendByEmail(_ description: String, _ data: Data) {
                let messageBody = description
               
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setMessageBody(messageBody, isHTML: true)
                    mail.addAttachmentData(data, mimeType: "image/jpeg", fileName: "attachment")
                    present(mail, animated: true)
                } else {
                    print("You can handle the method if your device cannot send Email")
                }
            }
    }

extension ListViewController: UITableViewDelegate, UITableViewDataSource,  MFMailComposeViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getCount() 
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
        return tableView.frame.height / 7
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
                    let item = self.viewModel.getList()[indexPath.row]
                    self.sendByEmail(item.desc, Data(base64Encoded: item.imageData)!)
                }
            
            let edit = UIContextualAction(
                style: .normal,
                title: "Edit") { action, view, completionHandler in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
                    vc.modalPresentationStyle = .formSheet
                    vc.currentRow = indexPath.row
                    let currentItem = self.viewModel.getList()[indexPath.row]
                    vc.defaultDesc = currentItem.desc
                    vc.updateCallback = { [weak self] (row, desc) in
                        self?.viewModel.editDesc(row: row, desc: desc)
                    }
                    self.present(vc, animated: true)
                }
            
            return UISwipeActionsConfiguration(actions: [delete, send, edit])
        }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Cancelled case")
        case .saved:
            print("Saved case")
        case .failed:
            print("Failed case")
        case .sent:
            print("Sent case")
        default:
            break
        }
        controller.dismiss(animated: true)
    }
}

