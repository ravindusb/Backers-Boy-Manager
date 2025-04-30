//
//  Helper.swift
//  Tailors Book
//
//  Created by Vijay Parmar on 07/07/19.
//  Copyright © 2019 Vijay Parmar. All rights reserved.
//

import Foundation
import UIKit

var arrFiles = NSMutableArray()
var arrImg = NSMutableArray()
var lblNotification : UILabel?
let bounds = UIScreen.main.bounds
var AppName = "Cake Shop Manager"
var noInternetMsg = "Oops! Not Connected to Internet,Please Check Your data Connection"

var selectedItemId = String()
var selectedType = String()
var selectedCustName = String()
var selectedCustPhone = String()

var userName : String{
    
    get{
        if UserDefaults.standard.value(forKey: "userName") != nil{
            return (UserDefaults.standard.value(forKey: "userName") as? String)!
        }
        return ""
    }
    
    set{
        UserDefaults.standard.set(newValue, forKey: "userName")
    }
    
}

var isLogin : Bool{
    
    get{
        if UserDefaults.standard.value(forKey: "isLogin") != nil{
            return (UserDefaults.standard.value(forKey: "isLogin") as? Bool)!
        }
        return false
    }
    
    set{
        UserDefaults.standard.set(newValue, forKey: "isLogin")
    }
    
}


var userEmail : String{
    
    get{
        if UserDefaults.standard.value(forKey: "userEmail") != nil{
            return (UserDefaults.standard.value(forKey: "userEmail") as? String)!
        }
        return ""
    }
    
    set{
        UserDefaults.standard.set(newValue, forKey: "userEmail")
    }
    
}

var shopName : String{
    
    get{
        if UserDefaults.standard.value(forKey: "shopName") != nil{
            return (UserDefaults.standard.value(forKey: "shopName") as? String)!
        }
        return ""
    }
    
    set{
        UserDefaults.standard.set(newValue, forKey: "shopName")
    }
    
}

var userID : String{
    
    get{
        if UserDefaults.standard.value(forKey: "userID") != nil{
            return (UserDefaults.standard.value(forKey: "userID") as? String)!
        }
        return ""
    }
    
    set{
        UserDefaults.standard.set(newValue, forKey: "userID")
    }
    
}

var userImage : String{
    
    get{
        if UserDefaults.standard.value(forKey: "userImage") != nil{
            return (UserDefaults.standard.value(forKey: "userImage") as? String)!
        }
        return ""
    }
    
    set{
        UserDefaults.standard.set(newValue, forKey: "userImage")
    }
    
}

func isConnectedToNetwork() -> Bool {
    
    var status:Bool = false
    
    let url = NSURL(string: "https://google.com")
    let request = NSMutableURLRequest(url: url! as URL)
    request.httpMethod = "HEAD"
    request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 10.0
    
    var response:URLResponse?
    
    do {
        let _ = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData?
    }
    catch let _ as NSError {
        //print(error.localizedDescription)
    }
    
    if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
            status = true
        }
    }
    return status
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    
    func callNumber() {
        
        
        var number = self.replacingOccurrences(of: "-", with: "")
        number = number.replacingOccurrences(of: "(", with: "")
        number = number.replacingOccurrences(of: ")", with: "")
        number = number.replacingOccurrences(of: " ", with: "")
        
        if let phoneCallURL = URL(string: "telprompt://\(number)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL as URL)
                }
            }
        }
    }
    
}

/* ====   MARK: RELOAD VIEW CONTROLLER  ==== */
extension UIViewController {
    func reloadViewFromNib() {
        let parent = view.superview
        view.removeFromSuperview()
        view = nil
        parent?.addSubview(view) // This line causes the view to be reloaded
    }
    
    func globalAlert(msg: String) {
        let alertView:UIAlertView = UIAlertView()
        alertView.title = AppName
        alertView.message = msg
        alertView.delegate = self
        alertView.addButton(withTitle: "OK")
        
        alertView.show()
        
    }
    
}


extension UITableView{
    
    func noDataLabel(message : String){
        let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        noDataLabel.text          = message
        noDataLabel.textColor     = UIColor.white
        noDataLabel.textAlignment = .center
        self.backgroundView  = noDataLabel
        self.separatorStyle  = .none
    }
    
    
}

extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}

