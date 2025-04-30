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

class AddItemVC: UIViewController {

   
    @IBOutlet weak var txtItemName :UITextField!
    @IBOutlet weak var txtPrice :UITextField!
    @IBOutlet weak var txtviewDesc :UITextView!
    @IBOutlet weak var txtStock  :UITextField!
    @IBOutlet weak var imgItemPic :UIImageView!
    
    var ref : DatabaseReference!
    var imagePicker = UIImagePickerController()
    var strImageUrl = ""
    var isImageSelected = false
    var dictData = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        self.imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnActionAddProfile(_ sender :UIButton){
        self.view.endEditing(true)
        self.pickerOpen(sender: sender)
    }
    
    
    @IBAction func btnActionBack(_ sender: UIButton) {
        
            self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnActionAddCustomer(_ sender :UIButton){
        if  isValidInput(){
            if isGuest{
                let alert = UIAlertController(title: AppName, message: "Please Login To Add Your Item", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
                    AppDelegate.shared.navToLogin()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                addCustomer()
            }
            
        }
        
    }
    
    func isValidInput()->Bool{
        if imgItemPic.image == UIImage(named: "ic_addImage"){
            self.globalAlert(msg: "Please Select Image")
            return false
        }
        if txtItemName.text!.isBlank{
            self.globalAlert(msg: "Please Enter Item Name")
            return false
        }
        else if txtPrice.text!.isBlank{
            self.globalAlert(msg: "Please Enter Price Per Pcs.")
            return false
        }
        else if txtStock.text!.isBlank{
            self.globalAlert(msg: "Please Enter Available Stock")
            return false
        }
        return true
    }
    
    func addCustomer(){
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        let userData = self.ref.child("items").childByAutoId()
        let url = "\(userData)"
        let arrPart = url.components(separatedBy: "/")
        
        let arrUserData = [
            "userId"          : userID,
            "itemId"          : arrPart[arrPart.count - 1],
            "image"           : "",
            "name"            : txtItemName.text!,
            "price"           : txtPrice.text!,
            "stock"           : txtStock.text!,
            "desc"            : txtviewDesc.text!
            ] as [String : Any]
        
        //CREATE DIVER NODE
        // let userData = self.ref.child("birthdays").child(userId)
        userData.setValue(arrUserData)
        if self.isImageSelected{
            SVProgressHUD.dismiss()
            storeImage(customerId: arrPart[arrPart.count - 1])
        }else{
            SVProgressHUD.dismiss()
            self.alert()
        }
    }
    
    func alert(){
        let uiAlert = UIAlertController(title: AppName, message: "Item Added Successfully", preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        uiAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            //MARK: SET LOCAL NOTIFICATION
            self.view.endEditing(true)
            self.txtItemName.text = ""
            self.txtviewDesc.text = ""
            self.txtPrice.text = ""
            self.txtStock.text = ""
            self.imgItemPic.image = #imageLiteral(resourceName: "ic_price")
           // self.dismiss(animated: true, completion: nil)
            
        }))
    
        // self.present(uiAlert, animated: true, completion: nil)
    }
    
    
    func storeImage(customerId : String){
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        let data = self.imgItemPic.image!.jpegData(compressionQuality: 0.3)! as NSData
        let sec = Int64(Date().timeIntervalSince1970 * 1000)
        let filePath   = "\(userID)_\(sec).jpg" // path where you wanted to store img in storage
        let metaData   = StorageMetadata()
        let storageRef = Storage.storage().reference().child(filePath)
        storageRef.putData(data as Data, metadata: metaData){(metaDatas,error) in
            if let error = error {
                self.globalAlert(msg: error.localizedDescription)
                SVProgressHUD.dismiss()
                return
            }else{
                storageRef.downloadURL(completion: { (url, error) in
                    if(error == nil){
                        self.strImageUrl = url!.absoluteString
                        //Save New Oreder in Firebase Database
                        let dictData = [
                            "image"        : self.strImageUrl
                            ] as [String : Any]
                        self.ref.child("items").child(customerId).updateChildValues(dictData)
                        SVProgressHUD.dismiss()
                        self.alert()
                        self.isImageSelected = false
                    }else {
                        self.globalAlert(msg: error!.localizedDescription)
                        SVProgressHUD.dismiss()
                    }
                })
            }
        }
    }
}
extension AddItemVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //MARK: Image Picker
    
    func pickerOpen(sender : UIButton){
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:-- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imgItemPic.image = image
            self.isImageSelected  = true
            // self.storeImage()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
   
    
}
