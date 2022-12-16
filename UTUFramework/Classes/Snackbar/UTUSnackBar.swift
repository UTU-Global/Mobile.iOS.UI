//
//  SnackBar.swift
//  SampleAlert
//
//  Created by Madhu on 28/04/20.
//  Copyright © 2020 Madhu. All rights reserved.
//

import UIKit
import MaterialComponents

public class UTUSnackBar : NSObject, MDCSnackbarManagerDelegate {
    var serviceDictionary : NSDictionary?
    static var snackbarTitle = ""
    static var isSuccess = false
    var customMessageView : UIView!
    var moreButton, statusButton : UIButton!
    static let messageAction = MDCSnackbarMessageAction()
    static let snackbarMessage = MDCSnackbarMessage()
    
    static var snackbarTitleLblHeight : CGFloat!
    static var defaultManager : MDCSnackbarManager!
    var snackbarTitleLbl : UILabel!
    var timer = Timer()
    //Singleton Implementation
    private static let sharedInstance:UTUSnackBar = {
        let instance = UTUSnackBar ()
        return instance
    } ()
    
    public static func showSnackbar(title: String){
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(closeAction), userInfo: nil, repeats: false)
        self.showSnackbar(title: title, forSuccess: false)
    }
    public static func showSnackbar(title: String, forSuccess : Bool){
        let actionHandler = {() in
            //todo
            MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: "infinite")
        }
        messageAction.handler = actionHandler
        snackbarMessage.action = messageAction
        snackbarTitle = title//"Wrong username or password, please check the credentials.Wrong username or password, please check the credentials.Wrong username or password, please check the credentials.Wrong username or password, please check the credentials."
        isSuccess = forSuccess
        defaultManager = MDCSnackbarManager()
        defaultManager.messageElevation = .none
        defaultManager.snackbarMessageViewShadowColor = .none
        defaultManager.snackbarMessageViewBackgroundColor = .lightGray
        defaultManager.messageTextColor = UIColor(red: 103/255, green: 103/255, blue: 103/255, alpha: 1)
        defaultManager.alignment = .center
        defaultManager.delegate = sharedInstance
        if UTUSnackBar.hasNotch() {
            defaultManager.setBottomOffset(UIScreen.main.bounds.height - 100)
        }else{
            defaultManager.setBottomOffset(UIScreen.main.bounds.height - 85)
        }
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(closeAction), userInfo: nil, repeats: false)
        defaultManager.alignment = .center
        defaultManager.shouldApplyStyleChangesToVisibleSnackbars = true
        defaultManager.messageTextColor = .black
        defaultManager.show(snackbarMessage)
        
        snackbarTitleLblHeight = UTUSnackBar.heightForView(text: title, font: UIFont(name: UTUFontNames.NotoSansRegular, size: 11)!, width: UIScreen.main.bounds.size.width - 96)
    }
    static func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    public func willPresentSnackbar(with messageView: MDCSnackbarMessageView?) {
        customMessageView = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height: 48))
        customMessageView.layer.cornerRadius = 4.0
        customMessageView.layer.borderWidth = 1
        customMessageView.layer.borderColor = UTUColors.white213.cgColor
        customMessageView.backgroundColor = UTUColors.white245
        statusButton = UIButton(frame: CGRect(x: 8, y: 11, width: 24, height: 25))
        let tickImg = UIImage(named: "check_circle", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        let infoImg = UIImage(named: "info", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        if UTUSnackBar.isSuccess {
            statusButton.setBackgroundImage(tickImg, for: .normal)
        }else{
            statusButton.setBackgroundImage(infoImg, for: .normal)//info
        }
        customMessageView.addSubview(statusButton)
        
        snackbarTitleLbl = UILabel(frame: CGRect(x: 40, y: 10, width: customMessageView.bounds.size.width - 40 - 10, height: 28))
        snackbarTitleLbl.text = UTUSnackBar.snackbarTitle
        snackbarTitleLbl.textAlignment = NSTextAlignment.left
        snackbarTitleLbl.numberOfLines = 1
        snackbarTitleLbl.textColor = .black//UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        snackbarTitleLbl.font = UIFont(name: UTUFontNames.NotoSansRegular, size: 12)
        customMessageView.addSubview(snackbarTitleLbl)
        //TapGesture
        let tapGesture = UITapGestureRecognizer()//target: self, action: #selector(moreAction)
        customMessageView.isUserInteractionEnabled = true
        tapGesture.numberOfTapsRequired = 1
        customMessageView.addGestureRecognizer(tapGesture)
        print(UTUSnackBar.snackbarTitleLblHeight!)
        if UTUSnackBar.snackbarTitleLblHeight <= 15.0 {
            UTUSnackBar.snackbarMessage.duration = 3.0
            customMessageView.isUserInteractionEnabled = false
            tapGesture.addTarget(self, action: #selector(closeAction))
        }else{
            UTUSnackBar.snackbarMessage.duration = 10.0
            tapGesture.addTarget(self, action: #selector(moreAction))
        }
        customMessageView.isUserInteractionEnabled = true
        messageView?.addSubview(customMessageView)
    }
    @objc func moreAction(){
        //let defaultManager = MDCSnackbarManager()
        UTUSnackBar.snackbarMessage.duration = 10.0
        if UTUSnackBar.hasNotch() {
            UTUSnackBar.defaultManager.setBottomOffset(UIScreen.main.bounds.height - 110)
        }else{
            UTUSnackBar.defaultManager.setBottomOffset(UIScreen.main.bounds.height - 100)
        }
        let count = UTUSnackBar.snackbarTitleLblHeight/15
        if count > 4 {
            UTUSnackBar.defaultManager.buttonFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 45)
            customMessageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height:UTUSnackBar.snackbarTitleLblHeight < 48 ? 48 : UTUSnackBar.snackbarTitleLblHeight + 10 )
        }else if count == 3 {
            UTUSnackBar.defaultManager.buttonFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 30)
            customMessageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height:75)
        }else{
            UTUSnackBar.defaultManager.buttonFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 23)
            customMessageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height:58)
        }
        moreButton = UIButton(frame: CGRect(x: customMessageView.frame.width - 30, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25))
        moreButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        let moreImg = UIImage(named: "cancel-24px", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        moreButton.setImage(moreImg, for: .normal)
        moreButton.isUserInteractionEnabled = false
        customMessageView.addSubview(moreButton)
        
        snackbarTitleLbl.frame = CGRect(x: 40, y: 5, width: customMessageView.bounds.size.width - 40 - 40, height:customMessageView.frame.height - 10)
        statusButton.frame = CGRect(x: 8, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25)
        snackbarTitleLbl.numberOfLines = 4
        customMessageView.isUserInteractionEnabled = false
    }
    @objc func closeAction(){
        //todo
        //messageInfinite.isNeedToDismiss = true
        UTUSnackBar.timer.invalidate()
        DispatchQueue.main.async {
            self.customMessageView.isUserInteractionEnabled = false
            MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: "infinite")
        }
    }
    static func hasNotch() -> Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
}
class UTUSnackbarMessage: MDCSnackbarMessage {
    override init() {
        super.init()
    }
    init(text: String) {
        super.init()
        self.text = text
    }
    
    public var isNeedToDismiss = false
    
    public var customDuration: TimeInterval = 9999999
    override var duration: TimeInterval {
        get {
            return isNeedToDismiss ? 3 : customDuration
        }
        set { }
    }
    
    public var customCategory: String? = "infinite"
    override var category: String? {
        get {
            return customCategory
        }
        set { }
    }
}
