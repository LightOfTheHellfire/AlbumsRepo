//
//  SectionViewController.swift
//  Metra
//
//  Created by Admin on 14.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class SectionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
//MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var section: Section?

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        if section != nil {
            nameTextField.text = section?.name
            if let description = section?.description {
                descriptionTextView.text = description
            }
        }
        nameTextField.placeholder = "Type name of section here.."
        nameTextField.delegate = self
        descriptionTextView.delegate = self    }

//MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if section != nil {
            section?.ref?.updateChildValues(["name" : nameTextField.text!])
            if let description = descriptionTextView.text {
                section?.description = description
                section?.ref?.updateChildValues(["description" : description])
            }
            dismiss(animated: true, completion: nil)
        } else {
            let dateFormatter  = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            section = Section(name: nameTextField.text!, description: descriptionTextView.text, date: dateFormatter.string(from: Date()))
            self.performSegue(withIdentifier: "unwindToSectionList", sender: self)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if nameTextField.text != nil {
            saveButton.isEnabled = true
        }
    }
}
