//
//  OrderListTVC.swift
//  Gift Shop Management
//
//  Created by Vijay Parmar on 16/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit

class OrderListTVC: UITableViewCell {

    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lblCustName: UILabel!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // viewBG.backgroundColor = UIColor.random()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
   
    
}
