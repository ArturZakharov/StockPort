//
//  StocksDetailsViewController.swift
//  StockPort
//
//  Created by ArturZaharov on 19.02.2021.
//

import UIKit
import CoreData

class StocksDetailsViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stockFullName: UILabel!
    @IBOutlet weak var stockPrice: UILabel!
    @IBOutlet weak var userWalletLabel: UILabel!
    @IBOutlet weak var countityStockTextField: UITextField!
    @IBOutlet weak var TotalAmountLabel: UILabel!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    //MARK:- Properties
    private let presenter = StocksDetailsPresenter(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    var stock: Stock?
    var buyButtonShow:Bool = true
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //    var userWallet: Double? {
    //        didSet{ userDefaults.set(userWallet, forKey: "wallet") }
    //    }
    
    
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.stock = stock
        presenter.setViewDelegate(stocksDetailsView: self)
        presenter.getStockInfo()
        countityStockTextField.addToolBarWithDoneButton()
        configureButtons()
        
        configPage()
    }
    
    private func configureButtons(){
        buyButton.layer.cornerRadius = 15
        sellButton.layer.cornerRadius = 15
        if !buyButtonShow {
            buyButton.isHidden = true
            
            DispatchQueue.main.async {
                //Changing constraint of stack view for one button
                let newConstraint = self.stackViewWidthConstraint.constraintWithMultiplier(0.45)
                self.superView.removeConstraint(self.stackViewWidthConstraint)
                self.superView.addConstraint(newConstraint)
                self.view.layoutIfNeeded()
                //self.stackViewWidthConstraint = newConstraint
            }
            
        }
    }
    
    private func configPage(){
        guard let userWallet = presenter.userWallet else { return }
        userWalletLabel.text = "Balance: \(presenter.getMoneyInCorrectForm(money: userWallet))"
        TotalAmountLabel.text = ""
        countityStockTextField.text = ""
    }
    
    @IBAction func buyButtontapped(_ sender: UIButton) {
        countityStockTextField.resignFirstResponder()
        
        guard let countityText = countityStockTextField.text else { return }
        guard let countity = Double(countityText) else { return }
        presenter.purchasingStock(countity: countity)
    }
    
    @IBAction func sellButtontapped(_ sender: Any) {
        countityStockTextField.resignFirstResponder()
        
        guard let countityText = countityStockTextField.text else { return }
        guard let countity = Double(countityText) else { return }
        presenter.sellStock(countity: countity)
    }
}

//MARK:- UITextFieldDelegate
extension StocksDetailsViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 270), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let countity = Double(textField.text ?? ""){
            let inTotal = countity * (stock?.price.regularMarketOpen.raw)!
            TotalAmountLabel.text = presenter.getMoneyInCorrectForm(money: inTotal)
        }
        
    }
}

extension StocksDetailsViewController: StocksDetailsViewDelegate {
    
    func showStockInfo(fullName: String, price: String, symbol: String) {
        stockFullName.text = fullName
        stockPrice.text = price
        self.title = symbol
    }
    
    func purchasingSuccses() {
        configPage()
    }
    
    func purchasingFaild(error: Error) {
        //to do alert to informat user
    }
    
    func sellStockSuccses(){
        configPage()
    }
    
    func sellStockFaild(error: Error){
        //to do alert to informat user
    }
}
