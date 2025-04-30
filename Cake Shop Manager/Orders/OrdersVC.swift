//
//  OrdersVC.swift
//  Gift Shop Management
//
//  Created by Vijay Parmar on 16/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD
import MessageUI

class OrdersVC: UIViewController {


    @IBOutlet weak var tblList : UITableView!
   
    var ref: DatabaseReference!
    var arrList  = NSMutableArray()
    var refreshControl = UIRefreshControl()
    var isAllOrders = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tblList.registerNib(nibName: "OrderListTVC")
        ref = Database.database().reference()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
       // tblList.addSubview(refreshControl)
    }
    
    @objc func refresh(sender:AnyObject) {
        if !isGuest{
            if isConnectedToNetwork(){
                self.getData()
            }else{
                self.globalAlert(msg: noInternetMsg)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if !isGuest{
            if isConnectedToNetwork(){
                self.getData()
            }else{
                self.globalAlert(msg: noInternetMsg)
            }
        }
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    
    @IBAction func btnActionAddItem(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddItemVC")as! AddItemVC
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func getData(){
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        //GET USER ID
        arrList = []
        
        self.ref = Database.database().reference()
        self.ref.child("orders").queryOrdered(byChild: "userId").queryEqual(toValue: userID).observeSingleEvent(of: .value) { (snapshot) in
            if !(snapshot.value is NSNull) {
                for child in snapshot.children {
                    //  let dict = (child as! DataSnapshot).value as! NSDictionary
                    self.arrList[self.arrList.count] = (child as! DataSnapshot).value as! NSDictionary
                    
                }
                SVProgressHUD.dismiss()
                self.tblList.backgroundView = nil
                self.tblList.reloadData()
            }
                
            else if self.arrList.count == 0{
                SVProgressHUD.dismiss()
                self.tblList.noDataLabel(message: "No Orders Available !")
                self.tblList.reloadData()
            }
            else{
                SVProgressHUD.dismiss()
                self.tblList.noDataLabel(message: "No Orders Available !")
                self.tblList.reloadData()
            }
        }
        
        refreshControl.endRefreshing()
    }
    
    
   
    
}


extension OrdersVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListTVC", for: indexPath)as! OrderListTVC
        let data = arrList[indexPath.row]as! NSDictionary
        cell.lblItemName.text = data.value(forKey: "itemName")as? String
        cell.lblCustName.text = data.value(forKey: "custName")as? String
        cell.lblDate.text = data.value(forKey: "orderDate")as? String
        cell.lblTotal.text = data.value(forKey: "total")as? String
        
        if let imgURL = data.value(forKey: "itemImage")as? String,imgURL.count>0{
            cell.imgItem.sd_setImage(with: URL(string: imgURL), placeholderImage: #imageLiteral(resourceName: "ic_gift"))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = arrList[indexPath.row]as! NSDictionary
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderDetailVC")as! OrderDetailVC
            vc.data = data
        self.present(vc, animated: true, completion: nil)
       
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let alert = UIAlertController(title: AppName, message: "Are you sure want to delete ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.ref = Database.database().reference()
                let groupRef = self.ref.child("orders").child(((self.arrList[indexPath.row]as? NSDictionary)?.value(forKey: "orderId")as? String)!)
                // ^^ this only works if the value is set to the firebase uid, otherwise you need to pull that data from somewhere else.
                groupRef.removeValue()
                self.getData()
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        }
    }
    

}
