//
//  ListTVC.swift
//  Tailors Book
//
//  Created by Vijay Parmar on 09/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import UIKit

class ListTVC: UITableViewCell {

   
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lblStock: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    var btnActionDetailTapped : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
     //  viewBG.backgroundColor = UIColor.random()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnActionDetail(_ sender: UIButton) {
        if let btnTapAction = btnActionDetailTapped{
            btnTapAction()
        }
    }
    
    
}

extension UIColor {
    func randomColor() -> UIColor {
        let colorsArray = [
            UIColor(red: 90/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0), //teal color
            UIColor(red: 222/255.0, green: 171/255.0, blue: 66/255.0, alpha: 1.0), //yellow color
            UIColor(red: 223/255.0, green: 86/255.0, blue: 94/255.0, alpha: 1.0), //red color
            UIColor(red: 239/255.0, green: 130/255.0, blue: 100/255.0, alpha: 1.0), //orange color
            UIColor(red: 77/255.0, green: 75/255.0, blue: 82/255.0, alpha: 1.0), //dark color
            UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0), //purple color
            UIColor(red: 85/255.0, green: 176/255.0, blue: 112/255.0, alpha: 1.0), //green color
        ]
        let unsignedArrayCount = UInt32(colorsArray.count)
        let unsignedRandomNumber = arc4random_uniform(unsignedArrayCount)
        let randomNumber = Int(unsignedRandomNumber)
        return colorsArray[randomNumber]
    }
}
