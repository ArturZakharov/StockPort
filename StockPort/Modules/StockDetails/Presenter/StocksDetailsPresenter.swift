//
//  StocksDetailsPresenter.swift
//  StockPort
//
//  Created by ArturZaharov on 01.04.2021.
//

import Foundation
import  CoreData

protocol StocksDetailsViewDelegate: AnyObject {
    func showStockInfo(fullName: String, price: String, symbol: String)
    func purchasingSuccses()
    func purchasingFaild(problem: String)
    func sellStockSuccses()
    func sellStockFaild(problem: String)
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
    var currentUserID: String?
    var user: User?
    var walletName: String?
    
    //MARK:- Functions
    init(context: NSManagedObjectContext) {
        self.context = context
        currentUserID = userDefaults.string(forKey: "currentUserID")
        getWalletName()
        prepareWallet()
        fetchUser()
    }
    
    func setViewDelegate(stocksDetailsView: StocksDetailsViewDelegate){
        self.viewDelegate = stocksDetailsView
    }
    
    func prepareWallet(){
        guard let walletName = walletName else { return }
        userWallet = userDefaults.double(forKey: walletName).rounded(toPlaces: 2)
    }
    
    func purchasingStock(countity: Double){
        guard let userWallet = userWallet else { return }
        guard let price = stock?.price.regularMarketOpen.raw else { return }
        guard let stock = stock else { return }
        guard let walletName = walletName else { return }
        
        let stockPriceSum = countity * price
        if stockPriceSum <= userWallet {
            let balance = userWallet - stockPriceSum
            self.userWallet! = balance
            self.viewDelegate?.purchasingSuccses()
            
            userDefaults.set(balance, forKey: walletName)
            
            //save the purchase in core data
            if let currentPurchasedStock = currentPurchasedStock {
                //TODO: to add to exicting stock the countity that was bought
                currentPurchasedStock.countity += countity
                
                saveDataToCoreData()
            } else {
                guard let user = user else { return }
                
                let newPurchased = PurchasedStock(context: self.context)
                newPurchased.stockSymbol = stock.symbol
                newPurchased.countity = countity
                newPurchased.owner = user
                currentPurchasedStock = newPurchased
                saveDataToCoreData()
                print("saved info SUCCSES")
            }
            
        } else {
            self.viewDelegate?.purchasingFaild(problem: "You don't have enought money to make this purchase")
        }
    }
    
    func sellStock(countity: Double){
        guard let userWallet = userWallet else { return }
        guard let price = stock?.price.regularMarketOpen.raw else { return }
        guard let currentPurchasedStock = currentPurchasedStock else {
            //viewDelegate?.SellStockFaild(error: )
            return
        }
        guard let walletName = walletName else { return }
        
        let stockPriceSum = countity * price
        
        if currentPurchasedStock.countity > countity {
            let newBalance = userWallet + stockPriceSum
            self.userWallet! = newBalance.rounded(toPlaces: 2)
            currentPurchasedStock.countity -= countity
            self.viewDelegate?.sellStockSuccses()
            userDefaults.set(newBalance, forKey: walletName)
            saveDataToCoreData()
        } else if currentPurchasedStock.countity == countity {
            let newBalance = userWallet + stockPriceSum
            self.userWallet! = newBalance.rounded(toPlaces: 2)
            self.context.delete(currentPurchasedStock)
            self.viewDelegate?.sellStockSuccses()
            userDefaults.set(newBalance, forKey: walletName)
            saveDataToCoreData()
        } else {
            self.viewDelegate?.sellStockFaild(problem: "You don't have enought stocks to make this sale")
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
    
    func fetchLocalData(){
        guard let stock = stock else {
            print("error: stock is nill")
            return
        }
        
        
        do {
            guard let user = user else { return }
            
            let requestStocks = PurchasedStock.fetchRequest() as NSFetchRequest<PurchasedStock>
            let predicate = NSPredicate(format: "stockSymbol CONTAINS '\(stock.symbol)' AND owner == %@", user)
            requestStocks.predicate = predicate
            let stocksArray = try context.fetch(requestStocks)
            
            
            if !stocksArray.isEmpty {
                print("the user have stocks")
                currentPurchasedStock = stocksArray[0]
            } else {
                print("this user dont have any of this stocks!!!")
            }
            
        } catch  {
            //TODO: problem fetching data
            print("problem fetching data from core data")
        }
    }
    
    func getStockInfo(){
        guard let stock = stock else { return }
        
        let name = stock.price.shortName
        let stockPrice = moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: stock.price.regularMarketOpen.raw!)
        let stockSymbol = stock.symbol
        viewDelegate?.showStockInfo(fullName: name, price: stockPrice, symbol: stockSymbol)
    }
    
    func getMoneyInCorrectForm(money: Double) -> String {
        return moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: money)
    }
    
    func fetchUser(){
        guard let currentUserID = currentUserID else {
            print("error: currentUserID is nill")
            return
        }
        
        do {
            let userRequest = User.fetchRequest() as NSFetchRequest<User>
            let predicateUser = NSPredicate(format: "userId CONTAINS '\(currentUserID)'")
            userRequest.predicate = predicateUser
            user = try context.fetch(userRequest)[0]
        } catch {
            print("eroor fetching user")
        }
    }
    
    func getWalletName(){
        guard let userID = currentUserID else { return }
        walletName = "wallet \(userID)"
    }
}
