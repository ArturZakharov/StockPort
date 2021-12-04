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
    
    
    private let presenter = SignInPresenter(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setViewDelegate(signinViewDelegate: self)
        self.hideKeyboardWhenTappedAround()
        self.passwordTextField.delegate = self
    }
   
    @IBAction func signInTapped(_ sender: Any) {
        let userName = userNameTextField.text
        let userPassword = passwordTextField.text
        
        //guard let userName = userName else { return }
        if let userName = userName, let userPassword = userPassword {
            presenter.checkIfUserExict(name: userName, password: userPassword)
            userNameTextField.text = ""
            passwordTextField.text = ""
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
            let userCheckPassword = alertController.textFields?[2].text ?? ""
            
            self.presenter.registerNewUser(name: userName, password: userPassword, checkPassword: userCheckPassword)
        }))
        
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

extension SignInViewController: SignInViewDelegate {
    func userExistPerformSegue() {
        performSegue(withIdentifier: "segueToMyPortfolio", sender: self)
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

