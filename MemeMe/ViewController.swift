//
//  ViewController.swift
//  MemeMe
//
//  Created by Nnabueze Uhiara on 19/04/2020.
//  Copyright © 2020 Nnabueze Uhiara. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet var selectedImagePreview: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    private var shouldClearTopText = true
    private var shouldClearBottomText = true
    private weak var activeTextField: UITextField!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  NSNumber(floatLiteral: -3.0)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleTextField(topTextField, Constants.TOP_TEXTFIELD_DEFAULT)
        styleTextField(bottomTextField, Constants.BOTTOM_TEXTFIELD_DEFAULT)
    }
    
    func styleTextField(_ textField: UITextField, _ defaultText: String) {
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
        textField.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = selectedImagePreview.image != nil
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField.tag == topTextField.tag && shouldClearTopText {
            textField.text = ""
            shouldClearTopText = false
        }
        else if textField.tag == bottomTextField.tag && shouldClearBottomText {
            textField.text = ""
            shouldClearBottomText = false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func pickAnImage(_ sender: UIBarButtonItem){
        let controller = UIImagePickerController()
        controller.delegate = self
        if sender.tag == 0 {
            controller.sourceType = .camera
        }
        else {
            controller.sourceType = .photoLibrary
        }
        present(controller, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            selectedImagePreview.image = selectedImage
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            shareButton.isEnabled = true
        }
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if activeTextField.tag == bottomTextField.tag {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func share(){
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = { [weak self] type, completed, items, error in
            if completed {
                self?.save(memedImage)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        present(controller, animated: true)
    }
    
    func save(_ memedImage: UIImage){
        let _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectedImagePreview.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return memedImage
    }
    
    @IBAction func cancelSelection() {
        shareButton.isEnabled = false
        selectedImagePreview.image = nil
        topTextField.isHidden = true
        bottomTextField.isHidden = true
        topTextField.text = Constants.TOP_TEXTFIELD_DEFAULT
        bottomTextField.text = Constants.BOTTOM_TEXTFIELD_DEFAULT
    }
 }
