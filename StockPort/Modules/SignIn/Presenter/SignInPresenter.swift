//
//  SignInPresenter.swift
//  StockPort
//
//  Created by ArturZaharov on 17.05.2021.
//

import Foundation
import CoreData
//SignInPresenter

protocol SignInViewDelegate: AnyObject {
    func showAlert(title: String, message: String)
    func userExistPerformSegue()
}

class SignInPresenter{
    
    private var context: NSManagedObjectContext
    let userDefaults = UserDefaults.standard
    private weak var viewDelegate: SignInViewDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func setViewDelegate(signinViewDelegate: SignInViewDelegate){
        viewDelegate = signinViewDelegate
    }
    
    func createNewUser(name: String, password: String){
        self.userDefaults.set(password, forKey: name)
        let user = User(context: context)
        user.userId = name
        saveDataToCoreData()
    }
    
    func registerNewUser(name: String, password: String, checkPassword: String){
        if password == "" || name == "" {
            viewDelegate?.showAlert(title: "Attention", message: "Some of the fields was empty, please fill all the fields")
        } else if password != checkPassword {
            viewDelegate?.showAlert(title: "Attention", message: "Password not match")
        } else if UserDefaults.standard.object(forKey: name) != nil{
            viewDelegate?.showAlert(title: "Attention", message: "This user name alredy used, please choose other user name")
        }
    
        viewDelegate?.showAlert(title: "Registration", message: "Successfully")
        createNewUser(name: name, password: password)
    }
    
    func checkIfUserExict(name: String, password: String){
        if name == "" || password == "" {
            viewDelegate?.showAlert(title: "Attention", message: "All the fields mast be filled")
        } else if userDefaults.string(forKey: name) == password {
            userDefaults.set(name, forKey: "currentUserID")
            viewDelegate?.userExistPerformSegue()
            
        } else {
            viewDelegate?.showAlert(title: "User not exist", message: "Check if you filled all the fields correctly")
        }
    }
    
    func saveDataToCoreData(){
        do {
            try self.context.save()
        } catch {
            //TODO: alert that was a problem with saving
            print("problem with saving to core data")
        }
    }
}
