//
//  SignInViewController.swift
//  StockPort
//
//  Created by ArturZaharov on 17.05.2021.
//

import UIKit

class SignInViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordEyeButton: UIButton!
    
    
    let userDefaults = UserDefaults.standard
   // var currentUser =
    
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.passwordTextField.delegate = self
    }
   
    @IBAction func signInTapped(_ sender: Any) {
        let userName = userNameTextField.text
        let userPassword = passwordTextField.text
        
        if userName == "" || userPassword == ""{
            self.showAlert(title: "Attention", message: "All the fields mast be filled")
        } else if userName == userDefaults.string(forKey: "userName") && userPassword == userDefaults.string(forKey: "Password") {
            performSegue(withIdentifier: "segueToMyPortfolio", sender: self)
            userNameTextField.text = ""
            passwordTextField.text = ""
        } else {
            self.showAlert(title: "User not exist", message: "Check if you filled all the fields correctly")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PortfolioViewController {
         //   viewController.currentUser =
        }
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Registration", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (_ textFiled: UITextField)  in
            textFiled.placeholder = "Enter name"
        }
        alertController.addTextField { (_ textFiled: UITextField)  in
            textFiled.placeholder = "Enter password"
            textFiled.isSecureTextEntry = true
        }
        alertController.addTextField { (_ textFiled: UITextField)  in
            textFiled.placeholder = "Repeat password"
            textFiled.isSecureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Register", style: .default, handler: { _ in
            
            let userName = alertController.textFields?[0].text ?? ""
            let userPassword = alertController.textFields?[1].text ?? ""
            let userRepeatedPassword = alertController.textFields?[2].text ?? ""
            
            if userPassword == "" || userName == "" {
                self.showAlert(title: "Attention", message: "Some of the fields was empty, please fill all the fields")
            } else if userPassword != userRepeatedPassword {
                //show alert password not match
                self.showAlert(title: "Attention", message: "Password not match")
            }
            
            self.userDefaults.set(userName, forKey: "userName")
            self.userDefaults.set(userPassword, forKey: "Password")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func passwordEyePressedDown(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = false
    }
    
    @IBAction func passwordEyeRelesed(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = true
    }
    
    
}


extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        signInTapped(self)
        return true
    }
}

