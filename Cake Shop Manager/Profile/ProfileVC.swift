//
//  ProfileVC.swift
//  Birthday Reminder
//
//  Created by Vijay Parmar on 27/06/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import SVProgressHUD
import FirebaseStorage

class ProfileVC: UIViewController {

    //@IBOutlet weak var totalThisMonth: UILabel!
    @IBOutlet weak var totalBirthdays: UILabel!
    @IBOutlet weak var lblName              : UILabel!
    @IBOutlet weak var lblEmail   : UILabel!
    @IBOutlet weak var imgViewProfile       : UIImageView!
    @IBOutlet weak var totalToday: UILabel!
    var ref : DatabaseReference!
    var imagePicker = UIImagePickerController()
  
    var strUrl = ""
    var isImageSelected = false
    var dictData = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        self.imagePicker.delegate = self
        lblName.text = userName
        lblEmail.text = userEmail
       
        if isConnectedToNetwork(){
            self.getData()
            self.getOrderData()
        }else{
            globalAlert(msg: "Oops! Not Connected to Internet,Please Check Your data Connection")
        }
        
       
    }
    @IBAction func btnActionLogout(_ sender: UIButton) {
        openLogout()
    }
    override func viewWillAppear(_ animated: Bool) {
        totalBirthdays.text = "\(intTotal)"
        totalToday.text = "\(intTotalOrders)"
        
    }
    @IBAction func btnProfileImgAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.pickerOpen(sender: sender)
    }

    fileprivate func openLogout() {
        let alertController = UIAlertController(title: "", message:"Are you sure you want to Sign Out?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
        }))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            AppDelegate.shared.navToLogin()
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func getOrderData(){
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        intTotalOrders = 0
        
        self.ref = Database.database().reference()
        self.ref.child("orders").queryOrdered(byChild: "userId").queryEqual(toValue: userID).observeSingleEvent(of: .value) { (snapshot) in
            if !(snapshot.value is NSNull) {
                for child in snapshot.children {
                    intTotalOrders = intTotalOrders + 1
                }
                self.totalToday.text = "\(intTotalOrders)"
                SVProgressHUD.dismiss()
            }
            else{
                SVProgressHUD.dismiss()
            }
        }
    }
    //GET USER INFO
    func getData(){
        
                SVProgressHUD.show()
                SVProgressHUD.setDefaultMaskType(.clear)
        
        //GET USER ID
       
        self.ref = Database.database().reference()
        self.ref.child("users").queryOrdered(byChild: "id").queryEqual(toValue: userID).observeSingleEvent(of: .value) { (snapshot) in
            
            if !(snapshot.value is NSNull) {
                for child in snapshot.children {
                    let dictData = (child as! DataSnapshot).value as! NSDictionary
                    userName = (dictData.value(forKey: "name")as? String)!
                    userEmail = (dictData.value(forKey: "email")as? String)!
                    self.lblName.text = userName
                    self.lblEmail.text = userEmail
                    if let imgURL = dictData.value(forKey: "image")as? String,imgURL.count > 0{
                        userImage = imgURL
                        self.imgViewProfile.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "ic_userph"))
                    }
                   
                }
                 SVProgressHUD.dismiss()
            }else{
                 SVProgressHUD.dismiss()
            }
            
        }
        
    }
    
    func storeImage(){
        
        SVProgressHUD.show()
        
        let data = self.imgViewProfile.image!.jpegData(compressionQuality: 0.3)! as NSData
        
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
                        self.strUrl = url!.absoluteString
                        userImage = url!.absoluteString
                        //ADD Client
                
                        //Save New Oreder in Firebase Database
                        let dictData = [
                            "image"        : self.strUrl
                            ] as [String : Any]
                        
                        self.ref.child("users").child(userID).updateChildValues(dictData)
                        SVProgressHUD.dismiss()
                        self.globalAlert(msg: "Profile Picture Updated.")
                        self.isImageSelected = false
                        //NotificationCenter.default.post(name: Notification.Name(rawValue: "setImage"), object: nil)
                    }else {
                        self.globalAlert(msg: error!.localizedDescription)
                        SVProgressHUD.dismiss()
                    }
                })
            }
        }
    }
}

extension ProfileVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
            self.imgViewProfile.image = image
            self.isImageSelected      = true
            self.storeImage()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
   
    
}
