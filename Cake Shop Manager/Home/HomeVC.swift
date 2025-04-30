//
//  HomeVC.swift
//  Tailors Book
//
//  Created by Vijay Parmar on 09/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD
import MessageUI

class HomeVC: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var tblList : UITableView!
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var ref: DatabaseReference!
    var arrList  = NSMutableArray()
    var arrMainList  = NSMutableArray()
    var refreshControl = UIRefreshControl()
    var isAllOrders = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        for view in searchBar.subviews.last!.subviews {
            if type(of: view) == NSClassFromString("UISearchBarBackground"){
                view.alpha = 0.0
            }
        }
       
        tblList.registerNib(nibName: "ListTVC")
        ref = Database.database().reference()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        //tblList.addSubview(refreshControl)
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
        arrMainList = []
        intTotal = 0
        
        self.ref = Database.database().reference()
        self.ref.child("items").queryOrdered(byChild: "userId").queryEqual(toValue: userID).observeSingleEvent(of: .value) { (snapshot) in
            if !(snapshot.value is NSNull) {
                for child in snapshot.children {
                    //  let dict = (child as! DataSnapshot).value as! NSDictionary
                     self.arrList[self.arrList.count] = (child as! DataSnapshot).value as! NSDictionary
                     self.arrMainList[self.arrMainList.count] = (child as! DataSnapshot).value as! NSDictionary
                     intTotal = intTotal + 1
                }
                SVProgressHUD.dismiss()
                 self.tblList.backgroundView = nil
                 self.tblList.reloadData()
            }
            
           else if self.arrList.count == 0{
                 SVProgressHUD.dismiss()
                self.tblList.noDataLabel(message: "No Items Available !")
                 self.tblList.reloadData()
            }
            else{
                SVProgressHUD.dismiss()
                self.tblList.noDataLabel(message: "No Items Available !")
                 self.tblList.reloadData()
            }
        }
        
        refreshControl.endRefreshing()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isBlank{
            arrList = arrMainList
            self.tblList.backgroundView = nil
            tblList.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "name contains[c] %@", searchText)
            self.arrList = NSMutableArray(array: self.arrMainList.filtered(using: resultPredicate))
            if arrList.count == 0{
                self.tblList.noDataLabel(message: "No Items in your search parameter")
            }else{
                self.tblList.backgroundView = nil
            }
            tblList.reloadData()
        }
    
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        self.view.endEditing(true)
    }
    
}


extension HomeVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTVC", for: indexPath)as! ListTVC
        let data = arrList[indexPath.row]as! NSDictionary
        cell.lblName.text = data.value(forKey: "name")as? String
        cell.lblPrice.text = data.value(forKey: "price")as? String
        cell.lblStock.text = data.value(forKey: "stock")as? String
        
        if let imgURL = data.value(forKey: "image")as? String,imgURL.count>0{
            cell.imgItem.sd_setImage(with: URL(string: imgURL), placeholderImage:#imageLiteral(resourceName: "candle"))
        }
        
        cell.btnActionDetailTapped = {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailVC")as! ItemDetailVC
            selectedItemId = data.value(forKey: "itemId")as? String ?? ""
            self.present(vc, animated: true, completion: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let data = arrList[indexPath.row]as! NSDictionary
        if data.value(forKey: "stock")as? String != "0"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemBillVC")as! ItemBillVC
            vc.data = data
            self.present(vc, animated: true, completion: nil)
        }else{
            self.globalAlert(msg: "Item is out of stock")
        }
       
    }
    
 
}
