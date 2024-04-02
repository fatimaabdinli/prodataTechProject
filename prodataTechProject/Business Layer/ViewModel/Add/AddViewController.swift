//
//  AddViewController.swift
//  prodataTechProject
//
//  Created by Fatima Abdinli on 30.03.24.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation
import RealmSwift

class AddViewController: UIViewController {
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var addDescripLabel: UILabel!
    @IBOutlet weak var addDescripTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    let imagePickerController = UIImagePickerController()
    internal var imageName: String?
    var saveCb: (() -> Void)?

    let viewModel = AddViewModel()
    let realm = RealmHelper.instance.realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTarget()
        setupView()
        imagePickerController.delegate = self
        print(realm.configuration.fileURL)
    }
    
    fileprivate func setupView() {
        saveButton.layer.cornerRadius = 8
        addDescripTextField.returnKeyType = .done
        addDescripTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        addDescripTextField.resignFirstResponder()
        return true
    }
    
    fileprivate func setupTarget() {
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonAction), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
    }
    
    @objc func addPhotoButtonAction() {
        showActionSheet()
//        checkPhotoLibraryPermission()
    }
    
    @objc func saveButtonAction() {
        guard let image = photoImage.image, let desc = addDescripTextField.text else {return}
        viewModel.saveObjectToRealm(image: image, desc: desc)
        saveCb?()
        self.dismiss(animated: true)
    }
    
    fileprivate func showActionSheet() {
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose photo source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take photo on camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            } else {
                self.noCameraAccess()
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose photo from photo library", style: .default, handler: { (action: UIAlertAction) in
            self.checkPhotoLibraryPermission()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion:  nil)
    }
    
    func noCameraAccess(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "This device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    func noLibraryAccess(){
        let alertVC = UIAlertController(
            title: "No Library Access",
            message: "Please give access to photo library",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    self.openPHPicker()
                    print("success")
                }
            })
            // no access to photo library
        case .restricted, .denied:
            noLibraryAccess()
            // access to all photos of library
        case .authorized:
            self.openPHPicker()
            // access to selected photos of library
        case .limited:
            self.openPHPicker()
        @unknown default:
            print(#function)
        }
    }

    func openPHPicker() {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
    }
}

// PHPicker extension
extension AddViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        results.forEach { result in
//            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: { (url, error) in
//                print(url?.lastPathComponent)
//                
//            })
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.photoImage.image = image
                    print(image.jpegData(compressionQuality: 0.8))
                    self.addPhotoButton.isHidden = true
                }
            }
        }
    }
}

