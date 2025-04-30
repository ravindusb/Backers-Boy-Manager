//
//  ItemBillVC.swift
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
import IQKeyboardManagerSwift

class ItemBillVC: UIViewController {

    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var txtCustomerName: UITextField!
    @IBOutlet weak var txtItemName: UITextField!
    @IBOutlet weak var txtQty: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtTotal: UITextField!
    @IBOutlet weak var txtNotes: IQTextView!
    
     var ref : DatabaseReference!
     var  data = NSDictionary()
     var intStock = Int()
     var itemId = String()
     var imageUrl = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        
        lblItemName.text = data.value(forKey: "name")as? String
        txtItemName.text = data.value(forKey: "name")as? String
        txtPrice.text = data.value(forKey: "price")as? String
        itemId = data.value(forKey: "itemId")as? String ?? ""
        txtQty.text = "1"
        let qty = txtQty.text!.isBlank ? 0 : Int(txtQty.text!)
        let prc = txtPrice.text!.isBlank ? 0 : Int(txtPrice.text!)
      //  txtTotal.text = "\(qty! * prc!)"
        
        intStock = Int((data.value(forKey: "stock")as! String))!
        if let imgURL = data.value(forKey: "image")as? String,imgURL.count>0{
            self.imageUrl = imgURL
           imgItem.sd_setImage(with: URL(string: imgURL), placeholderImage: #imageLiteral(resourceName: "ic_gift"))
        }
    }
    
    @IBAction func btnActionBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnActonDone(_ sender: UIButton) {
        if isValidInput(){
            if isConnectedToNetwork(){
                self.addOrder()
            }
        }
        
    }
    @IBAction func textChangeAction(_ sender: UITextField) {
        let qty = txtQty.text!.isBlank ? 0 : Int(txtQty.text!)
        let prc = txtPrice.text!.isBlank ? 0 : Int(txtPrice.text!)
        txtTotal.text = "\(qty! * prc!)"
    }
    
    func isValidInput()->Bool{
        if imgItem.image == UIImage(named: "ic_addImage"){
            self.globalAlert(msg: "Please Select Image")
            return false
        }
        else if txtCustomerName.text!.isBlank{
            self.globalAlert(msg: "Please Enter Customer Name")
            return false
        }
        else if txtQty.text!.isBlank{
            self.globalAlert(msg: "Please Enter Quantity Name")
            return false
        }
        if txtItemName.text!.isBlank{
            self.globalAlert(msg: "Please Enter Item Name")
            return false
        }
        else if txtPrice.text!.isBlank{
            self.globalAlert(msg: "Please Enter Price Per Pcs")
            return false
        }
       
        return true
    }
    
    
    func addOrder(){
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        let userData = self.ref.child("orders").childByAutoId()
        let url = "\(userData)"
        let arrPart = url.components(separatedBy: "/")
        let sec = Date().toString(format: "ddMMyyyymmss")
        //let sec = Int64(Date().timeIntervalSince1970 * 1000)
        let orderDate = Date().toString(format: "dd/MM/yyyy")
        
        let arrUserData = [
            "userId"          : userID,
            "orderId"         : arrPart[arrPart.count - 1],
            "orderDate"       : orderDate,
            "custName"        : txtCustomerName.text!,
            "itemName"        : txtItemName.text!,
            "qty"             : txtQty.text!,
            "total"           : txtTotal.text!,
            "notes"           : txtNotes.text!,
            "price"           : txtPrice.text!,
            "orderNo"         : "#ORDER\(sec)",
            "orderStatus"     : "1",
            "itemImage"       : self.imageUrl
            ] as [String : Any]
        
        //CREATE DIVER NODE
        userData.setValue(arrUserData)
        let stock = intStock - (txtQty.text?.toInt())!
        let stockValue = [
            "stock"     : "\(stock)",
            ] as [String : Any]
        
         self.ref.child("items").child(itemId).updateChildValues(stockValue)
         SVProgressHUD.dismiss()
    
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SendMailVC")as! SendMailVC
        vc.data = arrUserData as NSDictionary
        self.present(vc, animated: true, completion: nil)
    }
    
}
