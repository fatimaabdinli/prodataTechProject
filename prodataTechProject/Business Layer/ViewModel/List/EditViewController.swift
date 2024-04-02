//
//  EditViewController.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 03.04.24.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var updateTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!

    var defaultDesc: String?
    var currentRow: Int?
    var updateCallback: ((Int, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTarget()
    }

    fileprivate func setupView() {
        updateButton.layer.cornerRadius = 8
        updateTextField.text = defaultDesc
    }

    fileprivate func setupTarget() {
        updateButton.addTarget(self, action: #selector(updateButtonAction), for: .touchUpInside)
    }
    
    @objc func updateButtonAction() {
        updateCallback?(currentRow ?? 0, updateTextField.text ?? "")
        self.dismiss(animated: true)
    }
    
}
