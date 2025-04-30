//
//  SearchVC.swift
//  Gift Shop Management
//
//  Created by Vijay Parmar on 16/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD
import MessageUI

class SearchVC: UIViewController,UISearchBarDelegate {
    
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var txtSearchBy: UITextField!
    @IBOutlet weak var tblList : UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var ref: DatabaseReference!
    var arrList  = NSMutableArray()
    var arrMainList  = NSMutableArray()
    var refreshControl = UIRefreshControl()
    var isAllOrders = false
    var pickerView = UIPickerView()
    var arrPicker = ["Customer Name","Item Name","Date"]
    var selectedSortby  = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        for view in searchBar.subviews.last!.subviews {
            if type(of: view) == NSClassFromString("UISearchBarBackground"){
                view.alpha = 0.0
            }
        }
        pickerView.delegate = self
        pickerView.dataSource = self
        txtSearchBy.inputView = pickerView
        txtSearchBy.text = arrPicker[0]
        tblList.registerNib(nibName: "OrderListTVC")
        ref = Database.database().reference()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tblList.addSubview(refreshControl)
        self.tblList.noDataLabel(message: "No orders in your search parameter !")
        if isConnectedToNetwork(){
            self.getData()
        }else{
            self.globalAlert(msg: noInternetMsg)
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
//        if !isGuest{
//            if isConnectedToNetwork(){
//                self.getData()
//            }else{
//                self.globalAlert(msg: noInternetMsg)
//            }
//        }
//        super.viewWillAppear(animated);
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
                   // self.arrList[self.arrList.count] = (child as! DataSnapshot).value as! NSDictionary
                    self.arrMainList[self.arrMainList.count] = (child as! DataSnapshot).value as! NSDictionary
                    
                }
                SVProgressHUD.dismiss()
                self.tblList.backgroundView = nil
                self.tblList.reloadData()
            }
                
            else if self.arrList.count == 0{
                SVProgressHUD.dismiss()
                self.tblList.noDataLabel(message: "No orders in your search parameter !")
                self.tblList.reloadData()
            }
            else{
                SVProgressHUD.dismiss()
                self.tblList.noDataLabel(message: "No orders in your search parameter !")
                self.tblList.reloadData()
            }
        }
        
        refreshControl.endRefreshing()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var resultPredicate = NSPredicate(format: "custName contains[c] %@", searchText)
        
        if selectedSortby == 1{
            resultPredicate = NSPredicate(format: "itemName contains[c] %@", searchText)
        }else if selectedSortby == 2 {
            resultPredicate = NSPredicate(format: "orderDate contains[c] %@", searchText)
        }
        self.arrList = NSMutableArray(array: self.arrMainList.filtered(using: resultPredicate))
        if arrList.count == 0{
            self.tblList.noDataLabel(message: "No orders in your search parameter")
        }else{
            self.tblList.backgroundView = nil
        }
        tblList.reloadData()
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
       self.view.endEditing(true)
    }

    
}


extension SearchVC : UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return arrPicker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedSortby = row
        return arrPicker[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        txtSearchBy.text = arrPicker[row]
       // self.view.endEditing(true)
    }
    
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
    
}
