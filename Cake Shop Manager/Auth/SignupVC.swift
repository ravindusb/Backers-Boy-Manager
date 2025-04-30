//
//  SignupVC.swift
//  Tailors Book
//
//  Created by Vijay Parmar on 07/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
class SignupVC: UIViewController{
    
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtFullName: UITextField!
    
    @IBOutlet weak var txtShopName: UITextField!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ref = Database.database().reference()
    }
    
    // MARK: - Navigation
    @IBAction func btnActionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnActionSignUp(_ sender: UIButton) {
        
        
        self.view.endEditing(true)
        
        if(validateTextField()){
            //REGISTRATION
            getSignUpWithFirebase()
        }
    }
    
    
    // Validate Textfiled
    func validateTextField() -> Bool {
        
        if(txtFullName.text == "" || txtFullName.text!.trimmingCharacters(in: .whitespaces) == "" ){
            self.globalAlert(msg: "Please Enter Your Full Name")
            return false
        }
        else if(txtEmailAddress.text == "" || txtEmailAddress.text!.trimmingCharacters(in: .whitespaces) == ""){
            self.globalAlert(msg: "Please Enter Email Address")
            return false
        }
        else if(txtPassword.text == "" || txtPassword.text!.trimmingCharacters(in: .whitespaces) == ""){
            self.globalAlert(msg: "Please Enter Password")
            return false
        }
        else if(txtConfirmPass.text == "" || txtConfirmPass.text!.trimmingCharacters(in: .whitespaces) == ""){
            self.globalAlert(msg: "Please Enter Confirm Password")
            return false
        }
        else if(txtPassword.text! !=  txtConfirmPass.text!){
            self.globalAlert(msg: "Password does not match the confirm password")
            return false
        }
        return true
    }
    
    
    
    //MARK: SIGN UP WITH FIRE BASE
    func getSignUpWithFirebase(){
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        Auth.auth().createUser(withEmail: self.txtEmailAddress.text!, password: self.txtPassword.text!) { (result, error) in
            
            if(error == nil){ // CREATE SUCCESSFULLY
                
                //FIREBASE USER ID
                let userId = Auth.auth().currentUser?.uid
                
                //SetData For New User in Firebase Database
                let arrUserData = [
                    
                    "name"          : self.txtFullName.text!,
                    "email"         : self.txtEmailAddress.text!,
                    "id"            : userId!,
                    "shopName"      : self.txtShopName.text!,
                    "image"         : ""
                    ] as [String : Any]
                
                //CREATE DIVER NODE
                let userData = self.ref.child("users").child(userId!)
                userData.setValue(arrUserData)
                SVProgressHUD.dismiss()
                self.alert()
                
            }
            else{
                SVProgressHUD.dismiss()
                self.globalAlert(msg: error!.localizedDescription)
            }
        }
    }
    
    
    func alert(){
        
        let uiAlert = UIAlertController(title: AppName, message: "Accoount Successfully Created.", preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.navigationController!.popViewController(animated: true)
        }))
        
        // self.present(uiAlert, animated: true, completion: nil)
    }
    
}
