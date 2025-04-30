//
//  SendMailVC.swift
//  Gift Shop Management
//
//  Created by Vijay Parmar on 16/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit
import MessageUI
class SendMailVC: UIViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var txtEmail :UITextField!
    
    var data = NSDictionary()
    var strMailString = String()
    override func viewDidLoad() {
        super.viewDidLoad()

       let orderNo =  data.value(forKey: "orderNo")as? String
        let customer = data.value(forKey: "custName")as? String
        let itemName = data.value(forKey: "itemName")as? String
        let orderDate = data.value(forKey: "orderDate")as? String
        let qty = data.value(forKey: "qty")as? String
        let price = data.value(forKey: "price")as? String
        let total = data.value(forKey: "total")as? String
        let notes = data.value(forKey: "notes")as? String
        
        strMailString = "Mr/Ms. \(customer!)\nOrder No : \(orderNo!)\nDate : \(orderDate!)\nItem Name : \(itemName!)\nQuantity : \(qty!)\nPrice : \(price!)\nTotal : \(total!)\nNote : \(notes!)"
        
    }
    
    @IBAction func btnActionSend(_ sender: UIButton) {
        
        if txtEmail.text!.isBlank{
         
            self.globalAlert(msg: "Please Enter Email Id")
            
        }else{
            
            let mailComposeViewController = configureMailComposer()
            if MFMailComposeViewController.canSendMail(){
                self.present(mailComposeViewController, animated: true, completion: nil)
            }else{
                print("Can't send email")
            }
            
        }
    }
    
    @IBAction func btnActionCancel(_ sender: UIButton) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion:nil)
    }
    
    func configureMailComposer() -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([self.txtEmail.text!])
        mailComposeVC.setSubject("Gift Invoice from \(shopName)")
        mailComposeVC.setMessageBody(strMailString, isHTML: false)
        return mailComposeVC
    }
    
    //MARK: - MFMail compose method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
