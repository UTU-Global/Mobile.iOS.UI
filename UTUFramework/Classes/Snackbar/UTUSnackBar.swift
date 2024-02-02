//
//  SnackBar.swift
//  SampleAlert
//
//  Created by Lakshmana Sattineedi on 28/04/20.
//  Copyright © 2020 UTU. All rights reserved.
//
import UIKit
import MaterialComponents
import TTGSnackbar

public class UTUSnackBar : NSObject { //MDCSnackbarManagerDelegate
    public static var snackbar : TTGSnackbar!
    var serviceDictionary : NSDictionary?
    static var snackbarTitle = ""
    static var isSuccess = false
    static var customMessageView : UIView!
    static var moreButton, statusButton : UIButton!
    static let messageAction = MDCSnackbarMessageAction()
    static let snackbarMessage = MDCSnackbarMessage()
    
    static var snackbarTitleLblHeight : CGFloat!
    static var defaultManager : MDCSnackbarManager!
    static var snackbarTitleLbl : UILabel!
    static var timer = Timer()
    //Singleton Implementation
    private static let sharedInstance:UTUSnackBar = {
        let instance = UTUSnackBar ()
        return instance
    } ()
    
    public static func showSnackbar(title: String){
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(closeAction), userInfo: nil, repeats: false)
        self.showSnackbar(title: title, forSuccess: false)
    }
    public static func showSnackbar(title: String, forSuccess : Bool, bgColor: UIColor? = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1), titleColor: UIColor? = .black, borderColor:UIColor? = UIColor(red: 213/255, green: 213/255, blue: 213/255, alpha: 1)) {
        snackbarTitleLblHeight = self.heightForView(text: title, font: UIFont(name: UTUFontNames.NotoSansRegular, size: 12)!, width: UIScreen.main.bounds.size.width - 100)
        if snackbar != nil {
            snackbar.dismiss()
        }
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(closeAction), userInfo: nil, repeats: false)
        let snackbarTitle = title
        snackbar = TTGSnackbar(message: "", duration: .forever)
        snackbar.layer.shadowOpacity = 0
        snackbar.layer.shadowRadius = 0
        snackbar.layer.shadowColor = borderColor?.cgColor
        snackbar.layer.shadowOffset = CGSize(width: 0, height: 0)
        snackbar.backgroundColor = bgColor
        snackbar.frame = CGRect(x: 0, y: 0, width:snackbar.frame.width , height: snackbar.frame.height + 20)
        snackbar.leftMargin = 10
        snackbar.rightMargin = 10
        snackbar.messageTextFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 12)!
        snackbar.animationType = .slideFromTopToBottom
        snackbar.animationDuration = 0
        snackbar.show()
        //let screenSize = UIScreen.main.bounds
        customMessageView = UIView(frame: CGRect(x: 0, y: 0, width:snackbar.frame.width , height: snackbar.frame.height + 20))
        customMessageView.backgroundColor = bgColor
        customMessageView.layer.borderWidth = 1.0
        customMessageView.layer.borderColor = borderColor!.cgColor
        customMessageView.layer.cornerRadius = 3.0
        snackbar.addSubview(customMessageView)
        
        statusButton = UIButton(frame: CGRect(x: 8, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25))
        let tickImg = UIImage(named: "check_circle", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        let infoImg = UIImage(named: "info", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        if forSuccess {
            statusButton.setBackgroundImage(tickImg, for: .normal)
        } else {
            statusButton.setBackgroundImage(infoImg, for: .normal)//info
        }
        customMessageView.addSubview(statusButton)
        
        snackbarTitleLbl = UILabel(frame: CGRect(x: 40, y: 10, width: customMessageView.bounds.size.width - 40 - 10 - 30, height: snackbarTitleLblHeight))
        snackbarTitleLbl.text = snackbarTitle
        snackbarTitleLbl.textAlignment = NSTextAlignment.left
        snackbarTitleLbl.numberOfLines = 0
        snackbarTitleLbl.textColor = titleColor
        snackbarTitleLbl.font = UIFont(name: UTUFontNames.NotoSansRegular, size: 12)
        customMessageView.addSubview(snackbarTitleLbl)
        
        moreButton = UIButton(frame: CGRect(x: customMessageView.frame.width - 30, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25))
        moreButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        customMessageView.addSubview(moreButton)
        
        if forSuccess {
            statusButton.setBackgroundImage(tickImg, for: .normal)
            moreButton.setImage(UIImage(named: "close24Px", in:Bundle(identifier: "com.utu.utuframework") , compatibleWith: nil)?.setImageColor(UTUColors.appColor), for: .normal)
        } else {
            statusButton.setBackgroundImage(infoImg, for: .normal)
            moreButton.setImage(UIImage(named: "close24Px", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)?.setImageColor(UIColor(red: 210/255, green: 75/255, blue: 59/255, alpha: 1)), for: .normal)
        }
        moreButton.isUserInteractionEnabled = true
        statusButton.isUserInteractionEnabled = false
        snackbarTitleLbl.isUserInteractionEnabled = false
        customMessageView.isUserInteractionEnabled = true

        let count = snackbarTitleLblHeight/15
        if count >= 4 {
            snackbarTitleLbl.isUserInteractionEnabled = true
            customMessageView.frame = CGRect(x: 0, y: 0, width: customMessageView.frame.width, height: 85)
            snackbar.frame = CGRect(x: 0, y: 0, width: customMessageView.frame.width, height: 85)
        } else if count >= 3 {
            customMessageView.frame = CGRect(x: 0, y: 0, width: customMessageView.frame.width, height: 65)
            snackbar.frame = CGRect(x: 0, y: 0, width: customMessageView.frame.width, height: 65)
        } else {
            customMessageView.frame = CGRect(x: 0, y: 0, width: customMessageView.frame.width, height: 45)
            snackbar.frame = CGRect(x: 0, y: 0, width: customMessageView.frame.width, height: 45)
        }
        snackbarTitleLbl.frame = CGRect(x: 40, y: 5, width: customMessageView.bounds.size.width - 40 - 40, height: customMessageView.frame.height - 10)
        statusButton.frame = CGRect(x: 8, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25)
        moreButton.frame = CGRect(x: customMessageView.frame.width - 30, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25)
        snackbarTitleLbl.numberOfLines = 4
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(moreAction))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        snackbarTitleLbl.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc static func closeAction() {
        UTUSnackBar.timer.invalidate()
        UTUSnackBar.snackbar.dismiss()
    }
    @objc static func moreAction() {
        customMessageView.frame = CGRect(x: 0, y: 0, width: customMessageView.frame.width, height:snackbarTitleLblHeight + 20)
        moreButton.frame = CGRect(x: customMessageView.frame.width - 30, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25)
        snackbarTitleLbl.frame = CGRect(x: 40, y: 5, width: customMessageView.bounds.size.width - 40 - 40, height:customMessageView.frame.height - 10)
        statusButton.frame = CGRect(x: 8, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25)
        snackbarTitleLbl.numberOfLines = 0
        moreButton.isUserInteractionEnabled = true
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
    
    /*public static func showSnackbarOld(title: String, forSuccess : Bool) {
        let actionHandler = {() in
            //todo
            MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: "infinite")
        }
        messageAction.handler = actionHandler
        snackbarMessage.action = messageAction
        snackbarTitle = title
        isSuccess = forSuccess
        defaultManager = MDCSnackbarManager()
        defaultManager.hasMessagesShowingOrQueued()
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
        defaultManager.alignment = .center
        defaultManager.shouldApplyStyleChangesToVisibleSnackbars = true
        defaultManager.messageTextColor = .black
        defaultManager.messageFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 12)
        defaultManager.show(snackbarMessage)
        snackbarTitleLblHeight = UTUSnackBar.heightForView(text: title, font: UIFont(name: UTUFontNames.NotoSansRegular, size: 12)!, width: UIScreen.main.bounds.size.width - 96)
    }
     public func willPresentSnackbar(with messageView: MDCSnackbarMessageView?) {
        customMessageView = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height: 48))
        customMessageView.layer.cornerRadius = 4.0
        customMessageView.layer.borderWidth = 1
        customMessageView.layer.borderColor = UTUColors.white213.cgColor
        customMessageView.backgroundColor = UTUColors.white245
        statusButton = UIButton(frame: CGRect(x: 8, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25))
        let tickImg = UIImage(named: "check_circle", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        let infoImg = UIImage(named: "info", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        if UTUSnackBar.isSuccess {
            statusButton.setBackgroundImage(tickImg, for: .normal)
        } else {
            statusButton.setBackgroundImage(infoImg, for: .normal)//info
        }
        customMessageView.addSubview(statusButton)
        
        snackbarTitleLbl = UILabel(frame: CGRect(x: 40, y: 10, width: customMessageView.bounds.size.width - 40 - 10 - 30, height: 28))
        snackbarTitleLbl.text = UTUSnackBar.snackbarTitle
        snackbarTitleLbl.textAlignment = NSTextAlignment.left
        snackbarTitleLbl.numberOfLines = 4
        snackbarTitleLbl.textColor = .black
        snackbarTitleLbl.font = UIFont(name: UTUFontNames.NotoSansRegular, size: 12)
        customMessageView.addSubview(snackbarTitleLbl)
        //TapGesture
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        customMessageView.addGestureRecognizer(tapGesture)
        print(UTUSnackBar.snackbarTitleLblHeight!)
        tapGesture.addTarget(self, action: #selector(closeAction))
        
        messageView?.addSubview(customMessageView)
        
        
        customMessageView.isUserInteractionEnabled = false
        snackbarTitleLbl.isUserInteractionEnabled = false
        
        snackbarTitleLbl.layer.borderWidth = 0.5
        snackbarTitleLbl.layer.borderColor = UIColor.red.cgColor
        
        customMessageView.layer.borderWidth = 0.5
        customMessageView.layer.borderColor = UIColor.green.cgColor
        
        
        UTUSnackBar.snackbarMessage.duration = MDCSnackbarMessageDurationMax
        if UTUSnackBar.hasNotch() {
            UTUSnackBar.defaultManager.setBottomOffset(UIScreen.main.bounds.height - 110)
        }else{
            UTUSnackBar.defaultManager.setBottomOffset(UIScreen.main.bounds.height - 100)
        }
        let count = UTUSnackBar.snackbarTitleLblHeight/15
        if count > 4 {
            UTUSnackBar.defaultManager.buttonFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 60)
            customMessageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height:UTUSnackBar.snackbarTitleLblHeight < 48 ? 48 : UTUSnackBar.snackbarTitleLblHeight)
        } else if count == 3 {
            UTUSnackBar.defaultManager.buttonFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 30)
            customMessageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height:75)
        } else {
            UTUSnackBar.defaultManager.buttonFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 23)
            customMessageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height:58)
        }
        
        moreButton = UIButton(frame: CGRect(x: customMessageView.frame.width - 30, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25))
        moreButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        let moreImg = UIImage(named: "cancel-24px", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        moreButton.setImage(moreImg, for: .normal)
        moreButton.isUserInteractionEnabled = false
        moreButton.layer.borderWidth = 0.5
        moreButton.layer.borderColor = UIColor.blue.cgColor
        customMessageView.addSubview(moreButton)
        
        
        snackbarTitleLbl.frame = CGRect(x: 40, y: 5, width: customMessageView.bounds.size.width - 40 - 40, height:customMessageView.frame.height - 10)
        statusButton.frame = CGRect(x: 8, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25)
        snackbarTitleLbl.numberOfLines = 4
        customMessageView.isUserInteractionEnabled = false
        
    }
    @objc func moreAction(){
        //let defaultManager = MDCSnackbarManager()
        UTUSnackBar.snackbarMessage.duration = 10.0
        if UTUSnackBar.hasNotch() {
            UTUSnackBar.defaultManager.setBottomOffset(UIScreen.main.bounds.height - 110)
        }else{
            UTUSnackBar.defaultManager.setBottomOffset(UIScreen.main.bounds.height - 100)
        }
        UTUSnackBar.defaultManager.buttonFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 23)
        customMessageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height:58)
        moreButton = UIButton(frame: CGRect(x: customMessageView.frame.width - 30, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25))
        moreButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        let moreImg = UIImage(named: "cancel-24px", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
        moreButton.setImage(moreImg, for: .normal)
        moreButton.isUserInteractionEnabled = false
        customMessageView.addSubview(moreButton)
        
        snackbarTitleLbl.frame = CGRect(x: 40, y: 5, width: customMessageView.bounds.size.width - 40 - 40, height:customMessageView.frame.height - 10)
        statusButton.frame = CGRect(x: 8, y: (customMessageView.frame.height/2) - 12, width: 24, height: 25)
        snackbarTitleLbl.numberOfLines = 0
        customMessageView.isUserInteractionEnabled = false
    }
    @objc func closeAction() {
        DispatchQueue.main.async {
            self.customMessageView.isUserInteractionEnabled = false
            MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: "infinite")
        }
    }
    static func hasNotch() -> Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    static func dismissSnackBar(){
        MDCSnackbarManager.default.dismissAndCallCompletionBlocks(withCategory: nil)
    }
    */
}
/*class UTUSnackbarMessage: MDCSnackbarMessage {
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
*/
extension UIImage {
    func setImageColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
        color.setFill()
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
        ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return colored
    }
}
