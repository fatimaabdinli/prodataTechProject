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
import FirebaseStorage
import FirebaseFirestore

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTarget()
        setupView()
        imagePickerController.delegate = self
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
        saveButton.isEnabled = false
        
        do {
            if (self.imageName != nil && photoImage != nil && !(addDescripTextField.text ?? "").isEmpty) {
                let storageReference = Storage.storage().reference().child(self.imageName!)
                let imageData = self.photoImage!.image?.jpegData(compressionQuality: 0.8)
                guard let imageData = imageData else {return}
                let uploadTask = storageReference.putData(imageData, completion: { (storageMetaData, error) in
                    if let error = error {
                        return
                    }
                    
                    guard let storageMetaData = storageMetaData else {return}
                    
                    let db = Firestore.firestore()
                    db.collection("imageItems").document().setData(["imageName": storageMetaData.path, "description": self.addDescripTextField.text])
                    self.saveCb?()
                    self.dismiss(animated: true)
                })
            }
            
          } catch {
            print("Error on extracting data from url: \(error.localizedDescription)")
          }
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
    
//    public func checkForPermissions() {
//         
//           switch AVCaptureDevice.authorizationStatus(for: .video) {
//           case .authorized:
//               // The user has previously granted access to the camera.
//               break
//           case .notDetermined:
//               /*
//                The user has not yet been presented with the option to grant
//                video access. Suspend the session queue to delay session
//                setup until the access request has completed.
//                */
//               sessionQueue.suspend()
//               AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
//                   if !granted {
//                       self.setupResult = .notAuthorized
//                   }
//                   self.sessionQueue.resume()
//               })
//               
//           default:
//               // The user has previously denied access.
//               // Store this result, create an alert error and tell the UI to show it.
//               setupResult = .notAuthorized
//               
//               DispatchQueue.main.async {
//                   self.alertError = AlertError(title: "Camera Access", message: "SwiftCamera doesn't have access to use your camera, please update your privacy settings.", primaryButtonTitle: "Settings", secondaryButtonTitle: nil, primaryAction: {
//                           UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
//                                                     options: [:], completionHandler: nil)
//                       
//                   }, secondaryAction: nil)
//                   self.shouldShowAlertView = true
//                   self.isCameraUnavailable = true
//                   self.isCameraButtonDisabled = true
//               }
//           }
//       }
    
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
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.photoImage.image = image
                    self.addPhotoButton.isHidden = true
                }
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: {(url, error) in
                    DispatchQueue.main.async {
                        self.imageName = "\(result.itemProvider.suggestedName ?? "").\(url?.pathExtension ?? "")"
                    }
                })
            }
        }
    }
}
