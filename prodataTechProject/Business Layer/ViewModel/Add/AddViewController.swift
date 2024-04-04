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
        print(realm.configuration.fileURL!)
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
        
        actionSheet.addAction(UIAlertAction(title: "Take photo on camera", style: .default, handler: { [weak self] (action: UIAlertAction) in
            guard let self = self else {return}
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            } else {
                self.noCameraAccess()
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose photo from photo library", style: .default, handler: { [weak self] (action: UIAlertAction) in
            guard let self = self else {return}
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
    
    fileprivate func requestAuthorizationPhoto() {
        PHPhotoLibrary.requestAuthorization({
            [weak self ] (newStatus) in
            guard self != nil else {return}
            print("status is \(newStatus)")
        })
        
    }
    
    func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .notDetermined:
            requestAuthorizationPhoto()
            // no access to photo library
            break
        case .restricted, .denied:
            openSettings()
            // access to all photos of library
            break
        case .authorized:
            openPHPicker()
            // access to selected photos of library
        case .limited:
            openPHPicker()
        @unknown default:
            print(#function)
        }
    }
    
    func openPHPicker() {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
    }
    
    fileprivate func openSettings() {
        let alert = UIAlertController(title: "Location access required to get your current location", message: "Please allow location access", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { [weak self] action in
            guard self != nil else {return}
            
            // open Settings to allow access to library
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        alert.preferredAction = settingsAction
        
        self.present(alert, animated: true, completion: nil)
    }
}


// PHPicker extension
extension AddViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        results.forEach { [weak self] result in
            guard let self = self else {return}

            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let self = self else {return}
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.photoImage.image = image
                    self.addPhotoButton.isHidden = true
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            self.photoImage.image = editedImage
            self.addPhotoButton.isHidden = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

