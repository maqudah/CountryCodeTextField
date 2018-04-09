//
//  CountryCodeTextField.swift
//  CountryCodeTextField
//
//  Created by Mustafa Alqudah on 4/9/18.
//

import Foundation
import UIKit

@IBDesignable open class CountryCodeTextField: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {
    
    fileprivate var centerInset: CGFloat = 0
    fileprivate var pickerView = UIPickerView()
    fileprivate var contryCodeWidth: CGFloat = 0
    fileprivate var isCountryCodeHidden: Bool = false
    fileprivate var doneAction = UIAlertAction.init()
    fileprivate var cancelAction = UIAlertAction.init()
    fileprivate var contryCodeLabel: UILabel = UILabel()
    fileprivate var countriesCodes = [(String, String, String)]()
    fileprivate var countryAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
    
    @IBInspectable open var inset: CGFloat = 0 {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                self.update()
            #endif
        }
        willSet {
            if newValue < 0 {
                self.centerInset = 0
            }
            else {
                self.centerInset = newValue
            }
        }
    }
    
    @IBInspectable open var showCountryCode: Bool {
        get {
            return self.isCountryCodeHidden
        }
        set {
            self.isCountryCodeHidden = !newValue
            #if TARGET_INTERFACE_BUILDER
                self.update()
            #endif
        }
    }
    
    @IBInspectable open var contryCodeText: String? {
        get {
            return self.contryCodeLabel.text
        }
        set {
            let l = UILabel.init()
            l.text = newValue
            l.font = self.font
            self.contryCodeWidth = l.intrinsicContentSize.width + centerInset
            self.contryCodeLabel.text = newValue
        }
    }
    
    open var title: String? {
        get {
            return self.countryAlertController.title
        }
        set {
            self.countryAlertController.title = newValue
        }
    }
    
    open var doneButtonTitle: String? {
        get {
            return self.doneAction.title
        }
        set {
            if doneButtonTitle != nil {
                self.doneAction = UIAlertAction(title: self.doneButtonTitle, style: .default, handler: self.doneActionHandler)
            }
        }
    }
    
    open var cancelButtonTitle: String? {
        get {
            return self.cancelAction.title
        }
        set {
            if cancelButtonTitle != nil {
                self.cancelAction = UIAlertAction.init(title: self.cancelButtonTitle, style: .cancel, handler: nil)
            }
        }
    }
    
    open override var text: String? {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                self.update()
            #endif
        }
    }
    
    override open var textColor: UIColor? {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                self.update()
            #endif
            self.contryCodeLabel.textColor = self.textColor
        }
    }
    
    override open var font: UIFont? {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                self.update()
            #endif
            self.contryCodeLabel.font = self.font
        }
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let left = self.contryCodeWidth + 8
        return CGRect(x: left, y: bounds.origin.y, width: self.frame.width-(16+self.contryCodeWidth), height: bounds.height)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let left = self.contryCodeWidth + 8
        return CGRect(x: left, y: bounds.origin.y, width: self.frame.width-(16+self.contryCodeWidth), height: bounds.height)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        #if TARGET_INTERFACE_BUILDER
            self.update()
        #endif
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        #if TARGET_INTERFACE_BUILDER
            self.update()
        #endif
    }
    
    open override func awakeFromNib() {
        self.update()
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.contryCodeLabel.text = self.contryCodeText
    }
    
    fileprivate func update() {
        self.contryCodeLabel.textColor = self.textColor
        self.contryCodeLabel.font = self.font
        let l = UILabel.init()
        l.font = self.font
        l.text = self.contryCodeText
        self.contryCodeWidth = l.intrinsicContentSize.width + self.centerInset
        self.contryCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.contryCodeLabel)
        self.contryCodeLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        self.contryCodeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.contryCodeLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showVCAction(_:))))
        self.updateContryCodeLabel()
        
        #if !TARGET_INTERFACE_BUILDER
            self.doneAction = UIAlertAction(title: "Done", style: .default, handler: self.doneActionHandler)
            self.cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            
            let frameworkBundle = Bundle(for: self.classForCoder)
            
            print(frameworkBundle)
            if let docPath = frameworkBundle.path(forResource: "CountryCodeTextField.bundle/Settings.bundle/Countries Data/Codes", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: docPath), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? [Dictionary<String, Any>] {
                        for i in jsonResult {
                            self.countriesCodes.append(((i["name"] as! String), (i["dial_code"] as! String), (i["code"] as! String)))
                        }
                    }
                } catch {
                }
            }
            self.countryAlertController.title = self.title
            self.countryAlertController.message = "\n\n\n\n\n\n\n\n\n\n"
            self.countryAlertController.addAction(self.doneAction)
            self.countryAlertController.addAction(self.cancelAction)
            self.pickerView.delegate = self
            self.pickerView.dataSource = self
            self.countryAlertController.view.addSubview(self.pickerView)
        #endif
    }
    
    private func currentViewController() -> UIViewController? {
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    @objc func showVCAction(_ sender: Any) {
        if let vc = self.currentViewController() {
            self.pickerView.frame = CGRect(x: 0, y: 25, width: vc.view.frame.width-20, height: 190)
            vc.present(self.countryAlertController, animated: true, completion: nil)
        }
    }
    
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.countriesCodes.count
    }
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    lazy var doneActionHandler: ((UIAlertAction) -> Void)? = { action in
        self.contryCodeText = self.countriesCodes[self.pickerView.selectedRow(inComponent: 0)].1
    }
    
    func updateContryCodeLabel() {
        if self.isCountryCodeHidden {
            self.contryCodeLabel.text = nil
            self.contryCodeWidth = 0
            self.contryCodeLabel.isUserInteractionEnabled = false
        }
        else {
            let l = UILabel.init()
            l.font = self.font
            l.text = self.contryCodeText
            self.contryCodeWidth = l.intrinsicContentSize.width + self.centerInset
            self.contryCodeLabel.isUserInteractionEnabled = true
            self.contryCodeLabel.text = self.contryCodeText
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let codeLabel: UILabel = UILabel()
        view.addSubview(codeLabel)
        
        codeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        codeLabel.text = self.countriesCodes[row].1.padding(toLength: 6, withPad: " ", startingAt: 0)
        codeLabel.textAlignment = NSTextAlignment.justified
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        codeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        codeLabel.numberOfLines = 0
        
        let img = UIImage.init(named: "CountryCodeTextField.bundle/Settings.bundle/Countries Data/Flags/"+self.countriesCodes[row].2.uppercased(), in: Bundle(for: self.classForCoder), compatibleWith: nil)
        let flagImage: UIImageView = UIImageView.init(image: img)
        
        view.addSubview(flagImage)
        flagImage.translatesAutoresizingMaskIntoConstraints = false
        flagImage.leftAnchor.constraint(equalTo: codeLabel.rightAnchor, constant: 8).isActive = true
        flagImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        flagImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        flagImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
        flagImage.contentMode = .scaleAspectFit
        
        let countryLabel: UILabel = UILabel()
        view.addSubview(countryLabel)
        countryLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        countryLabel.text = self.countriesCodes[row].0
        countryLabel.textAlignment = NSTextAlignment.justified
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        countryLabel.leftAnchor.constraint(equalTo: flagImage.rightAnchor, constant: 4).isActive = true
        countryLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        countryLabel.numberOfLines = 0
        return view
    }
}
