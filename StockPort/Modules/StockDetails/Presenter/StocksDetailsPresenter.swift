//
//  StocksDetailsPresenter.swift
//  StockPort
//
//  Created by ArturZaharov on 01.04.2021.
//

import Foundation
import  CoreData

protocol StocksDetailsViewDelegate: class {
    func showStockInfo(fullName: String, price: String, symbol: String)
    func purchasingSuccses()
    func purchasingFaild(error: Error)
    func sellStockSuccses()
    func sellStockFaild(error: Error)
}

class StocksDetailsPresenter {
    
    //MARK:- Properties
    private weak var viewDelegate: StocksDetailsViewDelegate? { didSet{ fetchLocalData() } }
    
    var userWallet: Double?
    let userDefaults = UserDefaults.standard
    var stock: Stock?
    var currentPurchasedStock: PurchasedStock?
    private var context: NSManagedObjectContext
    private let moneyBuilder = MoneyBuilder()
    
    //MARK:- Functions
    init(context: NSManagedObjectContext) {
        self.context = context
        userWallet = userDefaults.double(forKey: "wallet").rounded(toPlaces: 2)
    }
    
    func setViewDelegate(stocksDetailsView: StocksDetailsViewDelegate){
        self.viewDelegate = stocksDetailsView
    }
    
    func purchasingStock(countity: Double){
        guard let userWallet = userWallet else { return }
        guard let price = stock?.price.regularMarketOpen.raw else { return }
        guard let safeStock = stock else { return }
        
        let stockPriceSum = countity * price
        if stockPriceSum <= userWallet {
            let balance = userWallet - stockPriceSum
            self.userWallet! = balance
            self.viewDelegate?.purchasingSuccses()
            
            //save the purchase in UserDefaults
            userDefaults.set(balance, forKey: "wallet")
            
            //save the purchase in core data
            if let currentPurchasedStock = currentPurchasedStock {
                //TODO: to add to exicting stock the countity that was bought
                currentPurchasedStock.countity += countity
                
                // print(currentPurchasedStock)
                print("we are in purchsed")
                saveDataToCoreData()
            } else {
                let newPurchased = PurchasedStock(context: self.context)
                newPurchased.stockASymbol = safeStock.symbol
                newPurchased.countity = countity
                currentPurchasedStock = newPurchased
                saveDataToCoreData()
            }
//            do {
//                try self.context.save()
//                print("the data saved")
//            } catch {
//                //TODO: alert that was a problem with saving
//                print("problem with saving to core data")
//            }
        } else {
            //TODO: to alert user that he doesnt have enough money in the wallet
        }
    }
    
    func sellStock(countity: Double){
        guard let userWallet = userWallet else { return }
        guard let price = stock?.price.regularMarketOpen.raw else { return }
        guard let safeStock = stock else { return }
        guard let currentPurchasedStock = currentPurchasedStock else {
            //viewDelegate?.SellStockFaild(error: )
            return
        }
        let stockPriceSum = countity * price
        
        if currentPurchasedStock.countity > countity {
            let newBalance = userWallet + stockPriceSum
            self.userWallet! = newBalance.rounded(toPlaces: 2)
            currentPurchasedStock.countity -= countity
            self.viewDelegate?.sellStockSuccses()
            userDefaults.set(newBalance, forKey: "wallet")
            saveDataToCoreData()
        } else if currentPurchasedStock.countity == countity {
            let newBalance = userWallet + stockPriceSum
            self.userWallet! = newBalance.rounded(toPlaces: 2)
            self.context.delete(currentPurchasedStock)
            self.viewDelegate?.sellStockSuccses()
            userDefaults.set(newBalance, forKey: "wallet")
            saveDataToCoreData()
        } else {
            //you cant sell not enough countity you have
        }
    }
    
    func saveDataToCoreData(){
        do {
            try self.context.save()
            print("the data saved")
        } catch {
            //TODO: alert that was a problem with saving
            print("problem with saving to core data")
        }
    }
    
    func fetchLocalData(){
        guard let stock = stock else { return }
        
        do {
            let request = PurchasedStock.fetchRequest() as NSFetchRequest<PurchasedStock>
            let pred = NSPredicate(format: "stockASymbol CONTAINS '\(stock.symbol)'")
            request.predicate = pred
            let purchasedStockOfCurrentType = try context.fetch(request)
            if purchasedStockOfCurrentType.count > 0 {
                currentPurchasedStock = purchasedStockOfCurrentType[0]
            }
            
        } catch  {
            //TODO: problem fetching data
            print("problem fetching data from core data")
        }
    }
    
    func getStockInfo(){
        guard let stock = stock else { return }
        
        let name = stock.price.shortName ?? ""
        let stockPrice = moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: stock.price.regularMarketOpen.raw!)
        let stockSymbol = stock.symbol
        viewDelegate?.showStockInfo(fullName: name, price: stockPrice, symbol: stockSymbol)
    }
    
    func getMoneyInCorrectForm(money: Double) -> String {
        return moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: money)
    }
}
