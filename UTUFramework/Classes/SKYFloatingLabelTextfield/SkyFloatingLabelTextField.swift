//  Copyright 2016-2019 Skyscanner Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
//  with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
//  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
//  for the specific language governing permissions and limitations under the License.

import UIKit

/**
 An enum for the possible error label placements.
 .default is the standard (on top) position; the error message is displayed in the `titleLabel`.
 .bottom displays the error below the text field in a dedicated `errorLabel`.
 */
public enum ErrorMessagePlacement {
    case `default`
    case bottom
}

/**
 A beautiful and flexible textfield implementation with support for title label, error message and placeholder.
 */
@IBDesignable
public class SkyFloatingLabelTextField: UITextField , UITextFieldDelegate{ // swiftlint:disable:this type_body_length
    
    let paddingEditing = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 50)
    var clearBtn : UIButton!
    public var isPasswordViewEnable : Bool = false
//    var passwordMaskBtn : UIButton!
    let maskLayer = CAShapeLayer()
    let borderLayer = CAShapeLayer()
    var path = UIBezierPath()
    var isCancelhidden = false
    /**
     A Boolean value that determines if the language displayed is LTR.
     Default value set automatically from the application language settings.
     */
    @objc open var isLTRLanguage: Bool = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
        didSet {
            updateTextAligment()
        }
    }
    
    fileprivate func updateTextAligment() {
        if isLTRLanguage {
            textAlignment = .left
            titleLabel.textAlignment = .left
            errorLabel.textAlignment = .left
        } else {
            textAlignment = .right
            titleLabel.textAlignment = .right
            errorLabel.textAlignment = .right
        }
        
        // Override error message default alignment
        if let errorLabelAlignment = errorLabelAlignment {
            errorLabel.textAlignment = errorLabelAlignment
        }
    }
    
    // MARK: Animation timing
    
    /// The value of the title appearing duration
    @objc dynamic open var titleFadeInDuration: TimeInterval = 0.2
    /// The value of the title disappearing duration
    @objc dynamic open var titleFadeOutDuration: TimeInterval = 0.3
    
    // MARK: Colors
    
    fileprivate var cachedTextColor: UIColor?
    
    /// A UIColor value that determines the text color of the editable text
    @IBInspectable
    override dynamic open var textColor: UIColor? {
        set {
            cachedTextColor = newValue
            updateControl(false)
        }
        get {
            return cachedTextColor
        }
    }
    
    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable dynamic open var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            updatePlaceholder()
        }
    }
    
    /// A UIFont value that determines text color of the placeholder label
    @objc dynamic open var placeholderFont: UIFont? = UIFont(name: UTUFontNames.NotoSansRegular, size: 16){
        didSet {
            updatePlaceholder()
        }
    }
    
    /// A `ErrorMessagePlacement` value that determines where the error message will be displayed.
    open var errorMessagePlacement: ErrorMessagePlacement = .default {
        didSet {
            updateControl()
            updatePlaceholder()
        }
    }
    
    /// An `NSTextAlignment` value that determines the error label text alignment.
    open var errorLabelAlignment: NSTextAlignment? {
        didSet {
            updateTextAligment()
        }
    }
    
    fileprivate func updatePlaceholder() {
        guard let placeholder = placeholder, let font = placeholderFont ?? font else {
            return
        }
        let color = isEnabled ? placeholderColor : disabledColor
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font
            ]
        )
        
    }
    
    /// A UIFont value that determines the text font of the title label
    @objc dynamic open var titleFont: UIFont = UIFont(name: UTUFontNames.NotoSansRegular, size: 13) ?? .systemFont(ofSize : 13){
        didSet {
            updateTitleLabel()
        }
    }
    
    /// A UIColor value that determines the text color of the title label when in the normal state
    @IBInspectable dynamic open var titleColor: UIColor = UIColor.lightGray  {
        didSet {
            updateTitleColor()
        }
    }
    
    /// A UIColor value that determines the color of the bottom line when in the normal state
    @IBInspectable dynamic open var lineColor: UIColor = .lightGray {
        didSet {
            updateLineView()
        }
    }
    
    /// A UIColor value that determines the color used for the label displaying the error message
    @IBInspectable dynamic open var errorColor: UIColor = .red {
        didSet {
            updateColors()
        }
    }
    
    /// A UIColor value that determines the color used for the line when error message is not `nil`
    @IBInspectable dynamic open var lineErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// A UIColor value that determines the color used for the text when error message is not `nil`
    @IBInspectable dynamic open var textErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// A UIColor value that determines the color used for the title label when error message is not `nil`
    @IBInspectable dynamic open var titleErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// A UIColor value that determines the color used for the title label and line when text field is disabled
    @IBInspectable dynamic open var disabledColor: UIColor = UIColor.orange//UIColor(white: 0.88, alpha: 1.0)
        {
        didSet {
            self.backgroundColor = UIColor.orange
            updateControl()
            updatePlaceholder()
        }
    }
    
    /// A UIColor value that determines the text color of the title label when editing
    @IBInspectable dynamic open var selectedTitleColor: UIColor = UTUColors.buttonBackgroundColor {
        didSet {
            updateTitleColor()
        }
    }
    
    /// A UIColor value that determines the color of the line in a selected state
    @IBInspectable dynamic open var selectedLineColor: UIColor = UTUColors.buttonBackgroundColor {
        didSet {
            updateLineView()
        }
    }
    
    // MARK: Line height
    
    /// A CGFloat value that determines the height for the bottom line when the control is in the normal state
    @IBInspectable dynamic open var lineHeight: CGFloat = 0.5 {
        didSet {
            updateLineView()
            setNeedsDisplay()
        }
    }
    
    /// A CGFloat value that determines the height for the bottom line when the control is in a selected state
    @IBInspectable dynamic open var selectedLineHeight: CGFloat = 1.0 {
        didSet {
            updateLineView()
            setNeedsDisplay()
            
        }
    }
    
    // MARK: View components
    
    /// The internal `UIView` to display the line below the text input.
    open var lineView: UIView!
    
    /// The internal `UILabel` that displays the selected, deselected title or error message based on the current state.
    open var titleLabel: UILabel!
    
    /// The internal `UILabel` that displays error messsage if `errorMessagePlacement` is `.bottom`.
    open var errorLabel: UILabel!
    
    // MARK: Properties
    
    /**
     The formatter used before displaying content in the title label.
     This can be the `title`, `selectedTitle` or the `errorMessage`.
     The default implementation converts the text to uppercase.
     */
    open var titleFormatter: ((String) -> String) = { (text: String) -> String in
        if #available(iOS 9.0, *) {
            return text//.localizedUppercase
        } else {
            return text//.uppercased()
        }
    }
    
    /**
     Identifies whether the text object should hide the text being entered.
     */
    override open var isSecureTextEntry: Bool {
        set {
            super.isSecureTextEntry = newValue
            fixCaretPosition()
        }
        get {
            return super.isSecureTextEntry
        }
    }
    
    /// A String value for the error message to display.
    @IBInspectable
    open var errorMessage: String? {
        didSet {
            updateControl(true)
        }
    }
    
    /// The backing property for the highlighted property
    fileprivate var _highlighted: Bool = false
    
    /**
     A Boolean value that determines whether the receiver is highlighted.
     When changing this value, highlighting will be done with animation
     */
    override open var isHighlighted: Bool {
        get {
//            print("isHighlighted")
            return _highlighted
        }
        set {
            _highlighted = newValue
            updateTitleColor()
            updateLineView()
        }
    }
    
    /// A Boolean value that determines whether the textfield is being edited or is selected.
    open var editingOrSelected: Bool {
    
        if !isEditing && !isSelected{

//            if self.text!.count > 0{
//                drawColored()
//            }else
            if self.text!.count > 0{
                drawLightGray()
            }
            self.clearBtn.isHidden = true

        }
        if isSelected || isEditing{
            drawColored()
        }
        return super.isEditing || isSelected
    }
    
    /// A Boolean value that determines whether the receiver has an error message.
    open var hasErrorMessage: Bool {
        return errorMessage != nil && errorMessage != ""
    }
    
    fileprivate var _renderingInInterfaceBuilder: Bool = false
    
    /// The text content of the textfield
    @IBInspectable
    override open var text: String? {
        didSet {
            updateControl(false)
        }
    }
    
    /**
     The String to display when the input field is empty.
     The placeholder can also appear in the title label when both `title` `selectedTitle` and are `nil`.
     */
    @IBInspectable
    override open var placeholder: String? {
        didSet {
            setNeedsDisplay()
            updatePlaceholder()
            updateTitleLabel()
        }
    }
    
    /// The String to display when the textfield is editing and the input is not empty.
    @IBInspectable open var selectedTitle: String? {
        didSet {
            updateControl()
        }
    }
    
    /// The String to display when the textfield is not editing and the input is not empty.
    @IBInspectable open var title: String? {
        didSet {
            updateControl()
        }
    }
    
    // Determines whether the field is selected. When selected, the title floats above the textbox.
    open override var isSelected: Bool {
        didSet {
            updateControl(true)
            drawColored()
        }
    }
    
    // MARK: - Initializers
    
    /**
     Initializes the control
     - parameter frame the frame of the control
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        init_SkyFloatingLabelTextField()
    }
    
    /**
     Intialzies the control by deserializing it
     - parameter aDecoder the object to deserialize the control from
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        borderStyle = .none
        bounds.inset(by: paddingEditing)
        init_SkyFloatingLabelTextField()
    }
    
    fileprivate final func init_SkyFloatingLabelTextField() {
        createTitleLabel()
        createLineView()
        createErrorLabel()
        updateColors()
        addEditingChangedObserver()
        updateTextAligment()
        self.delegate = self
    }
    
    fileprivate func addEditingChangedObserver() {
        self.addTarget(self, action: #selector(SkyFloatingLabelTextField.editingChanged), for: .editingChanged)
    }
    
    /**
     Invoked when the editing state of the textfield changes. Override to respond to this change.
     */
    @objc open func editingChanged() {
        updateControl(true)
        updateTitleLabel(true)
    }
    
    // MARK: create components
    
    fileprivate func createTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = titleFont
//        titleLabel.alpha = 1.0
        titleLabel.textColor = titleColor
        titleLabel.backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        
        let clearBtn = UIButton()
        addSubview(clearBtn)
        self.clearBtn = clearBtn
        self.clearBtn.isHidden = true
        
//        let passwordMaskBtn = UIButton()
//        addSubview(passwordMaskBtn)
//        self.passwordMaskBtn = passwordMaskBtn
//        self.passwordMaskBtn.isHidden = true
    }
    
    
    fileprivate func createErrorLabel() {
        let errorLabel = UILabel()
        errorLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        errorLabel.alpha = 0.0
        errorLabel.textColor = errorColor
        
        addSubview(errorLabel)
        self.errorLabel = errorLabel
    }
    
    fileprivate func createLineView() {
        
        if lineView == nil {
            let lineView = UIView()
            lineView.isUserInteractionEnabled = false
            self.lineView = lineView
            configureDefaultLineHeight()
        }
        
        //lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        //        addSubview(lineView)
    }
    
    fileprivate func configureDefaultLineHeight() {
        let onePixel: CGFloat = 1.0 / UIScreen.main.scale
        lineHeight = 2.0 * onePixel
        selectedLineHeight = 2.0 * self.lineHeight
    }
    
    // MARK: Responder handling
    
    /**
     Attempt the control to become the first responder
     - returns: True when successfull becoming the first responder
     */
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        setTitleVisible(true)
        self.drawColored()
        updateControl(true)
        self.isCancelhidden = false
        return result
    }

    /**
     Attempt the control to resign being the first responder
     - returns: True when successfull resigning being the first responder
     */
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        setTitleVisible(hasText || hasErrorMessage)
        self.drawLightGray()
        updateControl(true)
        self.clearBtn.isHidden = true
        return result
    }
    
    /// update colors when is enabled changed
    override open var isEnabled: Bool {
        didSet {
            updateControl()
            updatePlaceholder()
        }
    }
    
    // MARK: - View updates
    
    fileprivate func updateControl(_ animated: Bool = false) {
        updateColors()
        updateLineView()
        updateTitleLabel(false)
    }
    
    fileprivate func updateLineView() {
        guard let lineView = lineView else {
            return
        }
        
        lineView.frame = lineViewRectForBounds(bounds, editing: editingOrSelected)
        updateLineColor()
    }
    
    // MARK: - Color updates
    
    /// Update the colors for the control. Override to customize colors.
    open func updateColors() {
        updateLineColor()
        updateTitleColor()
        updateTextColor()
        updateErrorLabelColor()
    }
    
    fileprivate func updateErrorLabelColor() {
//        errorLabel.textColor = errorColor
    }
    
    fileprivate func updateLineColor() {
        guard let lineView = lineView else {
            return
        }
        
        if !isEnabled {
            lineView.backgroundColor = disabledColor
        } else if hasErrorMessage {
            lineView.backgroundColor = lineErrorColor ?? errorColor
        } else {
            lineView.backgroundColor = editingOrSelected ? selectedLineColor : lineColor
        }
    }
    
    fileprivate func updateTitleColor() {
        guard let titleLabel = titleLabel else {
            return
        }
        
        if !isEnabled {
            titleLabel.textColor = disabledColor
        } else if hasErrorMessage && errorMessagePlacement == .default {
            titleLabel.textColor = titleErrorColor ?? errorColor
        } else {
            if editingOrSelected || isHighlighted {
                titleLabel.textColor = selectedTitleColor
            } else {
                titleLabel.textColor = titleColor
            }
        }
    }
    
    fileprivate func updateTextColor() {
        if !isEnabled {
            super.textColor = disabledColor
        } else if hasErrorMessage {
            super.textColor = textErrorColor ?? errorColor
        } else {
            super.textColor = cachedTextColor
        }
    }
    
    // MARK: - Title handling
    
    fileprivate func updateTitleLabel(_ animated: Bool = false) {
        guard let titleLabel = titleLabel else {
            return
        }
        
        var titleText: String?
        var errorText: String?
        
        if errorMessagePlacement == .default {
            if hasErrorMessage {
                titleText = titleFormatter(errorMessage!)
            } else {
                if editingOrSelected {
                    titleText = selectedTitleOrTitlePlaceholder()
                    if titleText == nil {
                        titleText = titleOrPlaceholder()
                    }
                } else {
                    titleText = titleOrPlaceholder()
                }
            }
        } else {
            if hasErrorMessage {
                errorText = titleFormatter(errorMessage!)
            }
            if editingOrSelected {
                titleText = selectedTitleOrTitlePlaceholder()
                if titleText == nil {
                    titleText = titleOrPlaceholder()
                }
            } else {
                titleText = titleOrPlaceholder()
            }
        }
        titleLabel.text = titleText
        
        errorLabel.text = errorText
        errorLabel.font = titleFont
        updateTitleVisibility(animated)
        updateErrorVisibility(animated)
    }
    
    fileprivate var _titleVisible: Bool = false
    
    /*
     *   Set this value to make the title visible
     */
    open func setTitleVisible(
        _ titleVisible: Bool,
        animated: Bool = false,
        animationCompletion: ((_ completed: Bool) -> Void)? = nil
    ) {
        if _titleVisible == titleVisible {
            return
        }
        _titleVisible = titleVisible
        updateTitleColor()
        updateTitleVisibility(animated, completion: animationCompletion)
    }
    
    /**
     Returns whether the title is being displayed on the control.
     - returns: True if the title is displayed on the control, false otherwise.
     */
    open func isTitleVisible() -> Bool {
        if errorMessagePlacement == .default {
            return hasText || hasErrorMessage || _titleVisible
        } else {
            return hasText || _titleVisible
        }
    }
    
    open func isErrorVisible() -> Bool {
        return hasErrorMessage
    }
    
    fileprivate func updateTitleVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        
        let frame: CGRect = titleLabelRectForBounds(bounds, editing: isTitleVisible())
        let updateBlock = { () -> Void in
            
            self.titleLabel.frame = frame
            self.titleLabel.textAlignment = .center
            self.titleLabel.layer.masksToBounds = false

            //Clear button
            if self.isPasswordViewEnable{
//                self.isSecureTextEntry = true
//                let btnFrame : CGRect = CGRect(x: self.bounds.size.width-30,
//                                               y: self.bounds.size.height - self.textHeight() - self.textHeight()/4,
//                                               width: 24,
//                                               height: 24)
//                self.passwordMaskBtn.frame = btnFrame
//                self.isSecureTextEntry ?  self.passwordMaskBtn.setImage(UIImage(named: "ic_eye_closed"), for: .normal) : self.passwordMaskBtn.setImage(UIImage(named: "ic_eye_open"), for: .normal)
//                self.passwordMaskBtn.imageView?.contentMode = .scaleAspectFit
//                self.passwordMaskBtn.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
//                self.passwordMaskBtn.isHidden = false
//                self.clearBtn.isHidden = true
                
            }else{
                
                let btnFrame : CGRect = CGRect(x: self.bounds.size.width-30,
                                               y: self.bounds.size.height - self.textHeight() - self.textHeight()/4,
                                               width: 24,
                                               height: 24)
                self.clearBtn.frame = btnFrame
                
                let image = UIImage(named: "cancel-24px", in: Bundle(identifier: "com.utu.utuframework"), compatibleWith: nil)
                self.clearBtn.setImage(image, for: .normal)
                self.clearBtn.imageView?.contentMode = .scaleToFill
                self.clearBtn.addTarget(self, action: #selector(self.clearBtnClicked(sender:)), for: .touchUpInside)
                self.bringSubviewToFront(self.clearBtn)
                self.clearBtn.isHidden = true
            }
        }
        if animated {
            #if swift(>=4.2)
                let animationOptions: UIView.AnimationOptions = .curveEaseOut
            #else
                let animationOptions: UIViewAnimationOptions = .curveEaseOut
            #endif
            let duration = isTitleVisible() ? titleFadeInDuration : titleFadeOutDuration
            UIView.animate(withDuration: duration, delay: 1, options: animationOptions, animations: { () -> Void in
                updateBlock()
                }, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }
    
    @objc func clearBtnClicked(sender : UIButton){
        self.text = ""
        resignFirstResponder()
//        self.delegate?.textFieldShouldReturn?(self)
    }
    
//    @objc func togglePasswordView(sender : UIButton){
//        self.isSecureTextEntry ? passwordMaskBtn.setImage(UIImage(named: "ic_eye_open"), for: .normal) : passwordMaskBtn.setImage(UIImage(named: "ic_eye_closed"), for: .normal)
//        self.isSecureTextEntry = !self.isSecureTextEntry
//    }
//
    
    fileprivate func updateErrorVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        let alpha: CGFloat = isErrorVisible() ? 1.0 : 0.0
        let frame: CGRect = errorLabelRectForBounds(bounds, editing: isErrorVisible())
        let updateBlock = { () -> Void in
            self.errorLabel.alpha = alpha
            self.errorLabel.frame = frame
        }
        if animated {
            #if swift(>=4.2)
            let animationOptions: UIView.AnimationOptions = .curveEaseOut
            #else
            let animationOptions: UIViewAnimationOptions = .curveEaseOut
            #endif
            let duration = isErrorVisible() ? titleFadeInDuration : titleFadeOutDuration
            UIView.animate(withDuration: duration, delay: 1, options: animationOptions, animations: { () -> Void in
                updateBlock()
            }, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }
    
    // MARK: - UITextField text/placeholder positioning overrides
    
    /**
     Calculate the rectangle for the textfield when it is not being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds.inset(by: paddingEditing))
        let titleHeight = self.titleHeight()
        var height = superRect.size.height - titleHeight - selectedLineHeight
        if errorMessagePlacement == .bottom {
            height -= errorHeight()
        }
        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight-4,
            width: superRect.size.width,
            height: height+5
        )
        return rect
        
    }
    
    /**
     Calculate the rectangle for the textfield when it is being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds.inset(by: paddingEditing))
        let titleHeight = self.titleHeight()
        
        var height = superRect.size.height - titleHeight - selectedLineHeight
        if errorMessagePlacement == .bottom {
            height -= errorHeight()
        }
        
        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight-4,
            width: superRect.size.width,
            height: height+5
        )
        return rect
    }
    
    /**
     Calculate the rectangle for the placeholder
     - parameter bounds: The current bounds of the placeholder
     - returns: The rectangle that the placeholder should render in
     */
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        //        var height = bounds.size.height - titleHeight() - selectedLineHeight
        //        if errorMessagePlacement == .bottom {
        //            height -= errorHeight()
        //        }
        //        let rect = CGRect(
        //            x: 0,
        //            y: titleHeight(),
        //            width: bounds.size.width,
        //            height: height
        //        )
        //        return rect
        let superRect = super.editingRect(forBounds: bounds.inset(by: paddingEditing))
        let titleHeight = self.titleHeight()
        
        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight-8,
            width: bounds.size.width,
            height: bounds.size.height - titleHeight - selectedLineHeight)
        return rect
    }
    
    // MARK: - Positioning Overrides
    
    /**
     Calculate the bounds for the title label. Override to create a custom size title field.
     - parameter bounds: The current bounds of the title
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the title label should render in
     */
    func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        if editing {
            
            if isPasswordViewEnable{
                self.clearBtn.isHidden = true
            }else{
                self.clearBtn.isHidden = false
            }
//            drawColored()
            self.titleLabel.backgroundColor = UIColor.white
            self.titleLabel.layer.borderColor = UIColor.white.cgColor
            self.titleLabel.layer.borderWidth = 2
            self.titleLabel.layer.masksToBounds = false
            self.titleLabel.layer.shadowColor = UIColor.white.cgColor
            self.titleLabel.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
            self.titleLabel.layer.shadowOpacity = 1.0
            self.titleLabel.layer.shadowRadius = 1.0
            if isCancelhidden{
                self.clearBtn.isHidden = true
            }
            self.placeholderColor = UIColor.clear
            self.bringSubviewToFront(self.titleLabel)
            let width = self.placeholder?.size(OfFont: titleFont).width
            return CGRect(x: 16, y: bounds.origin.y-5, width: width!+4, height: titleHeight())
        }
        self.placeholderColor = UIColor.lightGray
        self.clearBtn.isHidden = true
        
//        print("_________________")
//        self.bringSubviewToFront(self.titleLabel)
        return CGRect(x: 0, y: titleHeight(), width: bounds.size.width, height: titleHeight())
    }
    
    
    /**
     Calculate the bounds for the error label. Override to create a custom size error field.
     - parameter bounds: The current bounds of the title
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the title label should render in
     */
    open func errorLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        if errorMessagePlacement == .default {
            return CGRect.zero
        } else {
            let lineRect = lineViewRectForBounds(bounds, editing: editing)
            if editing {
                let originY = lineRect.origin.y + selectedLineHeight
                return CGRect(x: 0, y: originY, width: bounds.size.width, height: errorHeight())
            }
            let originY = lineRect.origin.y + selectedLineHeight + errorHeight()
            return CGRect(x: 0, y: originY, width: bounds.size.width, height: errorHeight())
        }
    }
    
    /**
     Calculate the bounds for the bottom line of the control.
     Override to create a custom size bottom line in the textbox.
     - parameter bounds: The current bounds of the line
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the line bar should render in
     */
    open func lineViewRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let height = editing ? selectedLineHeight : lineHeight
        if errorMessagePlacement == .bottom {
            return CGRect(x: 0, y: textRect(forBounds: bounds).maxY, width: bounds.size.width, height: height)
        } else {
            return CGRect(x: 0, y: bounds.size.height - height, width: bounds.size.width, height: height)
        }
    }
    
    /**
     Calculate the height of the title label.
     -returns: the calculated height of the title label. Override to size the title with a different height
     */
    open func titleHeight() -> CGFloat {
        if let titleLabel = titleLabel,
            let font = titleLabel.font {
            return font.lineHeight
        }
        return 15.0
    }
    
    /**
     Calculate the height of the error label.
     -returns: the calculated height of the error label. Override to size the error with a different height
     */
    open func errorHeight() -> CGFloat {
        if let errorLabel = errorLabel,
            let font = errorLabel.font {
            return font.lineHeight
        }
        return 15.0
    }
    
    /**
     Calculate the height of the textfield.
     -returns: the calculated height of the textfield. Override to size the textfield with a different height
     */
    open func textHeight() -> CGFloat {
        guard let font = self.font else {
            return 0.0
        }
        
        return font.lineHeight + 7.0
    }
    
    // MARK: - Layout
    
    /// Invoked when the interface builder renders the control
    override open func prepareForInterfaceBuilder() {
        if #available(iOS 8.0, *) {
            super.prepareForInterfaceBuilder()
        }
        
        borderStyle = .none
        
        isSelected = true
        _renderingInInterfaceBuilder = true
        updateControl(false)
        invalidateIntrinsicContentSize()
    }
    
    /// Invoked by layoutIfNeeded automatically
    override open func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        titleLabel.frame = titleLabelRectForBounds(frame, editing: isTitleVisible() || _renderingInInterfaceBuilder)
        if !isEditing{
            self.clearBtn.isHidden = true
        }
    }
    
    /**
     Calculate the content size for auto layout
     
     - returns: the content size to be used for auto layout
     */
    override open var intrinsicContentSize: CGSize {
        if errorMessagePlacement == .bottom {
            return CGSize(width: bounds.size.width, height: titleHeight() + textHeight() + errorHeight())
        } else {
            return CGSize(width: bounds.size.width, height: titleHeight() + textHeight())
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func titleOrPlaceholder() -> String? {
        guard let title = title ?? placeholder else {
            return nil
        }
        return titleFormatter(title)
    }
    
    fileprivate func selectedTitleOrTitlePlaceholder() -> String? {
        guard let title = selectedTitle ?? title ?? placeholder else {
            return nil
        }
        return titleFormatter(title)
    }
    
    fileprivate func drawColored() {
        borderLayer.path = path.cgPath // Reuse the Bezier path
        borderLayer.frame = self.bounds
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UTUColors.buttonBackgroundColor.cgColor
        borderLayer.lineWidth = 1
        borderLayer.frame = self.bounds
        borderLayer.masksToBounds = false
        self.layer.addSublayer(borderLayer)
        
        self.titleLabel.textColor =  UTUColors.buttonBackgroundColor
        self.bringSubviewToFront(self.titleLabel)
    }
    
    fileprivate func drawLightGray() {
        borderLayer.path = path.cgPath // Reuse the Bezier path
        borderLayer.frame = self.bounds
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UTUColors.borderColor.cgColor
        borderLayer.lineWidth = 1
        borderLayer.frame = self.bounds
        borderLayer.masksToBounds = false
        self.layer.addSublayer(borderLayer)
        
//        self.titleLabel.textColor =  UIColor.lightGray
//        self.bringSubviewToFront(self.titleLabel)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
               context.saveGState()
               defer { context.restoreGState() }
               context.setFillColor(UTUColors.buttonBackgroundColor.cgColor);

               let lineFrame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y+3, width: self.bounds.size.width, height: self.bounds.size.height-3)
               path = UIBezierPath(roundedRect: lineFrame,
                                   byRoundingCorners: [.topLeft, .topRight,.bottomLeft, .bottomRight],
                                   cornerRadii: CGSize(width: 4, height: 4))
        if self.text!.count > 0{
            self.titleLabel.backgroundColor = UIColor.white
            self.titleLabel.layer.borderColor = UIColor.white.cgColor
            self.titleLabel.layer.borderWidth = 2
            self.titleLabel.layer.masksToBounds = false
            self.titleLabel.layer.shadowColor = UIColor.white.cgColor
            self.titleLabel.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
            self.titleLabel.layer.shadowOpacity = 1.0
            self.titleLabel.layer.shadowRadius = 1.0
            self.bringSubviewToFront(self.titleLabel)
            
            return
        }
        else if self.text!.count == 0{
            if !isHighlighted && !editingOrSelected{
                _ = titleLabelRectForBounds(frame, editing: false)
//                self.layoutSubviews()
//                self.delegate?.textFieldShouldReturn?(self)
                self.clearBtnClicked(sender: self.clearBtn)
            }
        }
        
        borderLayer.path = path.cgPath // Reuse the Bezier path
        borderLayer.frame = self.bounds
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UTUColors.borderColor.cgColor
        borderLayer.lineWidth = 1
        borderLayer.frame = self.bounds
        borderLayer.masksToBounds = false
        self.layer.addSublayer(borderLayer)
    }
    
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
//
//        if isPasswordViewEnable{
//            let textRange = Range(range, in: self.text!)
//            let updatedText = self.text!.replacingCharacters(in: textRange!, with: string)
//            if let text = self.text, let _ = Range(range, in: text) {
//                self.text = updatedText
//                return false
//            }
//        }
//        return true
//    }
    
//    override  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
//        self.isCancelhidden = false
//        return true
//    }
  
//    @discardableResult
//      override open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
//          let result = super.resignFirstResponder()
//
//          return result
//      }
//    - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text

}
