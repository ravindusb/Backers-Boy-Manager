//
//  UICollectionView+Extension.swift
//  Vijay Ladva
//
//  Created by Vijay Ladva on 28/03/18.
//  Copyright © 2018 Vijay Ladva. All rights reserved.
//

import UIKit
import Foundation
//import NVActivityIndicatorView


typealias ButtonClick = (_ button :UIButton) -> Void


extension String {
    func nsRange(from range: Range<String.Index>?) -> NSRange? {
        if let range = range{
            let utf16view = self.utf16
            if let from = range.lowerBound.samePosition(in: utf16view), let to = range.upperBound.samePosition(in: utf16view) {
                return NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from), utf16view.distance(from: from, to: to))
            }
        }
        return nil
    }
}

// Extesntion Declaration
extension UICollectionView{
    func registerNib(nibName : String){
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: nibName)
    }
    
//    public var isLoading : Bool{
//        get {
//            if let value = objc_getAssociatedObject(self, &AssociatedKeys.boolState) as? Bool{
//                return value
//            }
//            return false
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, &AssociatedKeys.boolState, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//
//
//    public func startLoader(){
//        let xPos = (self.frame.size.width / 2) - 17.5
//        let yPos = (self.frame.size.height / 2) - 17.5
//        let activityLoader = NVActivityIndicatorView(frame: CGRect(x: xPos, y: yPos, w: 35, h: 35), type: NVActivityIndicatorType.circleStrokeSpin, color: AppColor.LoaderColor, padding: nil)
//        let backgroundView = UIView(frame: self.frame)
//        backgroundView.addSubview(activityLoader)
//        self.backgroundView = backgroundView
//        activityLoader.startAnimating()
//        activityLoader.centerInSuperview()
//        self.isLoading = true
//    }
//
//    public func stopLoader(){
//        self.isLoading = false
//        self.backgroundView = nil
//    }
}


struct AssociatedKeys {
    static var boolState: UInt8 = 0
}
extension UITableView{
    
    public var isLoading : Bool{
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.boolState) as? Bool{
                return value
            }
            return false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.boolState, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func registerNib(nibName : String){
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: nibName)
    }
    
    func removeTopBottomSpace(){
        self.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, w: self.frame.size.width, h: 0.01))
        self.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, w: self.frame.size.width, h: 0.01))
    }
    
//    public func startLoader(){
//        let xPos = (self.frame.size.width / 2) - 17.5
//        let yPos = (self.frame.size.height / 2) - 17.5
//        let activityLoader = NVActivityIndicatorView(frame: CGRect(x: xPos, y: yPos, w: 35, h: 35), type: NVActivityIndicatorType.circleStrokeSpin, color: AppColor.LoaderColor, padding: nil)
//        let backgroundView = UIView(frame: self.frame)
//        backgroundView.addSubview(activityLoader)
//        self.backgroundView = backgroundView
//        activityLoader.startAnimating()
//        activityLoader.centerInSuperview()
//        self.isLoading = true
//    }
//
//    public func stopLoader(){
//        self.isLoading = false
//        self.backgroundView = nil
//    }
}

private var AssociatedObjectHandle: UInt8 = 0

extension UIImageView {
    
//    var loader : NVActivityIndicatorView?{
//        
//        get {
//            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? NVActivityIndicatorView
//        }
//        set {
//            if newValue == nil {
//                objc_removeAssociatedObjects(self)
//            }
//            else {
//                objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//    private func addLoader() {
//
//        if self.loader == nil {
//            let xPos = (self.frame.size.width / 2) - 17.5
//            let yPos = (self.frame.size.height / 2) - 17.5
//            loader = NVActivityIndicatorView(frame: CGRect(x: xPos, y: yPos, w: 35, h: 35), type: NVActivityIndicatorType.circleStrokeSpin, color: AppColor.LoaderColor, padding: nil)
//            loader?.startAnimating()
//            self.addSubview(loader!)
//        }
//    }
//
//    private func removeLoader() {
//        if self.loader != nil, self.loader!.superview != nil {
//            loader?.stopAnimating()
//            self.loader?.removeFromSuperview()
//            self.loader = nil
//        }
//    }
//
//    public func startLoading(){
//        self.addLoader()
//    }
//
//    public func stopLoading(){
//        self.removeLoader()
//    }

}

