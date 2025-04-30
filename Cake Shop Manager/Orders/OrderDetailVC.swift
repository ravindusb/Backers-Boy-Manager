//
//  OrderDetailVC.swift
//  Gift Shop Management
//
//  Created by Vijay Parmar on 16/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit

class OrderDetailVC: UIViewController {

    @IBOutlet weak var imgOrder: UIImageView!
    @IBOutlet weak var lblOrderNo: UILabel!
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    
  
    
    var data = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imgURL = data.value(forKey: "itemImage")as? String,imgURL.count>0{
            imgOrder.sd_setImage(with: URL(string: imgURL), placeholderImage: #imageLiteral(resourceName: "ic_gift"))
        }
        
        lblOrderNo.text = data.value(forKey: "orderNo")as? String
        lblCustomerName.text = data.value(forKey: "custName")as? String
        lblItemName.text = data.value(forKey: "itemName")as? String
        lblDate.text = data.value(forKey: "orderDate")as? String
        lblQuantity.text = data.value(forKey: "qty")as? String
        lblPrice.text = data.value(forKey: "price")as? String
        lblTotal.text = data.value(forKey: "total")as? String
        lblNotes.text = data.value(forKey: "notes")as? String
        
        
    }

    
    @IBAction func btnActionBack(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
