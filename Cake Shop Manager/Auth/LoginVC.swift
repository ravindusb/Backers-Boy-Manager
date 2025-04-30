//
//  LoginVC.swift
//  Tailors Book
//
//  Created by Vijay Parmar on 07/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
class LoginVC: UIViewController {
    
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    // MARK: - Navigation
    
    @IBAction func btnActionLogin(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if validateTextField() {
            getLoginWithFirebase()
        }
    }
    
    @IBAction func btnActionCreateAccount(_ sender: Any) {
        
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(signupVC, animated: true)
        
    }
    
    func validateTextField() -> Bool {
        if(txtEmail.text == "" || txtEmail.text!.trimmingCharacters(in: .whitespaces) == "" ){
            self.globalAlert(msg: "Please Enter Email Address")
            return false
        }
        else if(txtPassword.text == "" || txtPassword.text!.trimmingCharacters(in: .whitespaces) == ""){
            self.globalAlert(msg: "Please Enter Password")
            return false
        }
        return true
        
    }
    
    @IBAction func btnActionSkip(_ sender: UIButton) {
       isGuest = true
       AppDelegate.shared.navToHome()
        
    }
    
    //MARK: LOGIN WITH FIREBASE
    func getLoginWithFirebase() {
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        Auth.auth().signIn(withEmail: self.txtEmail.text!, password: self.txtPassword.text!) { (user, error) in
            if(error == nil){ // SUCCESSFULLY LOGIN
                // SAVE USER ID IN DEFAULT
                SVProgressHUD.dismiss()
                userID = Auth.auth().currentUser!.uid
                isLogin = true
                isGuest = false
                 AppDelegate.shared.navToHome()
            }else {
                SVProgressHUD.dismiss()
                self.globalAlert(msg: "Invalid Credential")
            }
        }
    }
    
}
