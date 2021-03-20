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
    var stock: Stock?
    var buyButtonShow:Bool = true
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let userDefaults = UserDefaults.standard
    var userWallet: Double? {
        didSet{ userDefaults.set(userWallet, forKey: "wallet") }
    }
    var currentPurchasedStock: PurchasedStock?
        
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        userWallet = userDefaults.double(forKey: "wallet").rounded(toPlaces: 2)
        countityStockTextField.addToolBarWithDoneButton()
        configureButtons()
        configPage()
        fetchLocalData()
    }
    
    private func configureButtons(){
        buyButton.layer.cornerRadius = 15
        sellButton.layer.cornerRadius = 15
        if !buyButtonShow {
            buyButton.isHidden = true
            
            DispatchQueue.main.async {
                //Changing constarit of stack view for one button
                let newConstraint = self.stackViewWidthConstraint.constraintWithMultiplier(0.45)
                self.superView.removeConstraint(self.stackViewWidthConstraint)
                self.superView.addConstraint(newConstraint)
                self.view.layoutIfNeeded()
                //self.stackViewWidthConstraint = newConstraint
            }
            
        }
    }
    
    private func configPage(){
        //TODO: userWallet unpack
        userWalletLabel.text = "Balance: \(userWallet!)$"
        guard let safeStock = stock else { return }
        stockFullName.text = safeStock.price.shortName
        //TODO: to unpack the optional price
        stockPrice.text = "\(safeStock.price.regularMarketOpen.raw!)"
        //stockCompanyDescription.text = safeStock.summaryProfile.longBusinessSummary
        self.title = safeStock.symbol
        TotalAmountLabel.text = ""
        countityStockTextField.text = ""
    }
    
    func fetchLocalData(){
        guard let safeStock = stock else { return }
        
        do {
            let request = PurchasedStock.fetchRequest() as NSFetchRequest<PurchasedStock>
            let pred = NSPredicate(format: "stockASymbol CONTAINS '\(safeStock.symbol)'")
            request.predicate = pred
            let purchasedStockOfCurrentType = try context.fetch(request)
            if purchasedStockOfCurrentType.count > 0 {
                currentPurchasedStock = purchasedStockOfCurrentType[0]
            }
            
        } catch  {
            //TODO: problem fetching data
        }
    }
    
    @IBAction func buyButtontapped(_ sender: UIButton) {
        countityStockTextField.resignFirstResponder()
        
        guard let countityText = countityStockTextField.text else { return }
        guard let userWallet = userWallet else { return }
        guard let countity = Double(countityText) else { return }
        guard let price = stock?.price.regularMarketOpen.raw else { return }
        guard let safeStock = stock else { return }
        
        let stockPriceSum = countity * price
        if stockPriceSum <= userWallet {
            
            self.userWallet! -= stockPriceSum
            configPage()
            //save the purchase in core data
            
            if let currentPurchasedStock = currentPurchasedStock {
                //TODO: to add to exicting stock the countity that was bought
                currentPurchasedStock.countity += countity
                print(currentPurchasedStock)
            } else {
                let newPurchased = PurchasedStock(context: self.context)
                newPurchased.stockASymbol = safeStock.symbol
                newPurchased.countity = countity
                currentPurchasedStock = newPurchased
            }
            do {
                try self.context.save()
            } catch {
                //TODO: alert that was a problem with saving
            }
        } else {
            //TODO: to alert user that he doesnt have enough money in the wallet
        }
    }
    
    @IBAction func sellButtontapped(_ sender: Any) {
        countityStockTextField.resignFirstResponder()
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
            TotalAmountLabel.text = "\(inTotal)"
        }
        
    }
}
