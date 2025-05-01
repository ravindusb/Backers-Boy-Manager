//
//  AddItemVC.swift
//  Gift Shop Management
//
//  Created by Vijay Parmar on 15/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import SVProgressHUD
import FirebaseStorage

/// ViewController responsible for adding new items to the shop
final class AddItemVC: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let imageCompressionQuality: CGFloat = 0.3
        static let defaultImageName = "ic_price"
        static let addImageName = "ic_addImage"
        static let imageFileExtension = "jpg"
        static let maxImageSize: CGFloat = 1024
        static let cornerRadius: CGFloat = 5
        static let borderWidth: CGFloat = 1
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var txtItemName: UITextField!
    @IBOutlet private weak var txtPrice: UITextField!
    @IBOutlet private weak var txtviewDesc: UITextView!
    @IBOutlet private weak var txtStock: UITextField!
    @IBOutlet private weak var imgItemPic: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private let ref = Database.database().reference()
    private let imagePicker = UIImagePickerController()
    private let storage = Storage.storage()
    private var isImageSelected = false
    private var isUploading = false
    private var keyboardHeight: CGFloat = 0
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
        SVProgressHUD.dismiss()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        imagePicker.allowsEditing = true
        setupTextFields()
        setupImageView()
        setupActivityIndicator()
    }
    
    private func setupDelegates() {
        imagePicker.delegate = self
        txtItemName.delegate = self
        txtPrice.delegate = self
        txtStock.delegate = self
        txtviewDesc.delegate = self
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTextFields() {
        txtPrice.keyboardType = .decimalPad
        txtStock.keyboardType = .numberPad
        
        [txtItemName, txtPrice, txtStock].forEach { textField in
            textField?.layer.cornerRadius = Constants.cornerRadius
            textField?.layer.borderWidth = Constants.borderWidth
            textField?.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        txtviewDesc.layer.cornerRadius = Constants.cornerRadius
        txtviewDesc.layer.borderWidth = Constants.borderWidth
        txtviewDesc.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupImageView() {
        imgItemPic.image = UIImage(named: Constants.defaultImageName)
        imgItemPic.contentMode = .scaleAspectFit
        imgItemPic.clipsToBounds = true
        imgItemPic.layer.cornerRadius = Constants.cornerRadius
        imgItemPic.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imgItemPic.addGestureRecognizer(tapGesture)
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
    }
    
    @objc private func imageTapped() {
        view.endEditing(true)
        showImagePickerOptions(sender: UIButton())
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardHeight = keyboardFrame.height
        adjustViewForKeyboard()
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        adjustViewForKeyboard()
    }
    
    private func adjustViewForKeyboard() {
        let duration = 0.3
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = -self.keyboardHeight
        }
    }
    
    private func isValidInput() -> Bool {
        guard let itemName = txtItemName.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let price = txtPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let stock = txtStock.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        
        if imgItemPic.image == UIImage(named: Constants.addImageName) {
            showAlert(message: "Please Select Image")
            return false
        }
        
        if itemName.isEmpty {
            showAlert(message: "Please Enter Item Name")
            return false
        }
        
        if price.isEmpty {
            showAlert(message: "Please Enter Price Per Pcs.")
            return false
        }
        
        if stock.isEmpty {
            showAlert(message: "Please Enter Available Stock")
            return false
        }
        
        return true
    }
    
    private func addItem() {
        guard !isUploading else { return }
        guard isValidInput() else { return }
        
        if isGuest {
            showLoginAlert()
            return
        }
        
        isUploading = true
        showLoading()
        
        let userData = ref.child("items").childByAutoId()
        let itemId = userData.key ?? UUID().uuidString
        
        let itemData: [String: Any] = [
            "userId": userID,
            "itemId": itemId,
            "image": "",
            "name": txtItemName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "price": txtPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "stock": txtStock.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "desc": txtviewDesc.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "createdAt": ServerValue.timestamp()
        ]
        
        userData.setValue(itemData) { [weak self] error, _ in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(error)
                return
            }
            
            if self.isImageSelected {
                self.storeImage(itemId: itemId)
            } else {
                self.handleSuccess()
            }
        }
    }
    
    private func storeImage(itemId: String) {
        guard let image = imgItemPic.image else {
            handleError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No image selected"]))
            return
        }
        
        let resizedImage = image.resized(to: Constants.maxImageSize)
        guard let imageData = resizedImage.jpegData(compressionQuality: Constants.imageCompressionQuality) else {
            handleError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"]))
            return
        }
        
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let filePath = "\(userID)_\(timestamp).\(Constants.imageFileExtension)"
        let storageRef = storage.reference().child(filePath)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(error)
                return
            }
            
            storageRef.downloadURL { [weak self] url, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.handleError(error)
                    return
                }
                
                guard let imageUrl = url?.absoluteString else {
                    self.handleError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL"]))
                    return
                }
                
                self.ref.child("items").child(itemId).updateChildValues(["image": imageUrl]) { error, _ in
                    if let error = error {
                        self.handleError(error)
                        return
                    }
                    
                    self.handleSuccess()
                }
            }
        }
    }
    
    private func showLoading() {
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        activityIndicator.startAnimating()
    }
    
    private func hideLoading() {
        SVProgressHUD.dismiss()
        activityIndicator.stopAnimating()
    }
    
    private func handleSuccess() {
        isUploading = false
        hideLoading()
        showSuccessAlert()
        isImageSelected = false
    }
    
    private func handleError(_ error: Error) {
        isUploading = false
        hideLoading()
        showAlert(message: error.localizedDescription)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: AppName, message: "Item Added Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.resetForm()
        })
        present(alert, animated: true)
    }
    
    private func showLoginAlert() {
        let alert = UIAlertController(title: AppName, message: "Please Login To Add Your Item", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
            AppDelegate.shared.navToLogin()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func resetForm() {
        view.endEditing(true)
        txtItemName.text = ""
        txtviewDesc.text = ""
        txtPrice.text = ""
        txtStock.text = ""
        imgItemPic.image = UIImage(named: Constants.defaultImageName)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: AppName, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction private func btnActionAddProfile(_ sender: UIButton) {
        view.endEditing(true)
        showImagePickerOptions(sender: sender)
    }
    
    @IBAction private func btnActionBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func btnActionAddCustomer(_ sender: UIButton) {
        addItem()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AddItemVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func showImagePickerOptions(sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.openCamera()
        })
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openGallery()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        }
        
        present(alert, animated: true)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: "Camera is not available")
            return
        }
        
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    private func openGallery() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            imgItemPic.image = image
            isImageSelected = true
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddItemVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate
extension AddItemVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to maxSize: CGFloat) -> UIImage {
        let scale = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? self
    }
}

