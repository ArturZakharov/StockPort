//
//  Extensions+TextField.swift
//  StockPort
//
//  Created by ArturZaharov on 10.03.2021.
//

import UIKit

extension UITextField {
    func addToolBarWithDoneButton(){
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, done], animated: true)
        self.inputAccessoryView = toolBar
    }
    
    @objc func doneTapped(){
        self.endEditing(true)
    }
}


 
