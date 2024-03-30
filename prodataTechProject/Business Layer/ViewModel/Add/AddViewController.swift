//
//  AddViewController.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 30.03.24.
//

import UIKit

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var addDescripLabel: UILabel!
    @IBOutlet weak var addDescripTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTarget()
        setupView()
    }
    
    fileprivate func setupView() {
        saveButton.layer.cornerRadius = 8
    }
    
    fileprivate func setupTarget() {
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonAction), for: .touchUpInside)
    }
    
    @objc func addPhotoButtonAction() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose photo source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take photo on camera", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose photo from photo library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            //            future releasede olmayacaq, deyir PHPicker islet!!!!
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion:  nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.photoImage.image = image
            self.addPhotoButton.isHidden = true
            picker.dismiss(animated: true)
        }
    }
}
