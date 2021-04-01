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
}

class StocksDetailsPresenter {
    
    //MARK:- Properties
    private weak var viewDelegate: StocksDetailsViewDelegate?
    var userWallet: Double?
    let userDefaults = UserDefaults.standard
    var stock: Stock?
    var currentPurchasedStock: PurchasedStock?
    private var context: NSManagedObjectContext
    
    //MARK:- Functions
    init(context: NSManagedObjectContext) {
        self.context = context
        userWallet = userDefaults.double(forKey: "wallet").rounded(toPlaces: 2)
        fetchLocalData()
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
            
            //save the purchase in core data
            if let currentPurchasedStock = currentPurchasedStock {
                //TODO: to add to exicting stock the countity that was bought
                currentPurchasedStock.countity += countity
                // print(currentPurchasedStock)
            } else {
                let newPurchased = PurchasedStock(context: self.context)
                newPurchased.stockASymbol = safeStock.symbol
                newPurchased.countity = countity
                currentPurchasedStock = newPurchased
            }
            do {
                try self.context.save()
                print("the data saved")
            } catch {
                //TODO: alert that was a problem with saving
                print("problem with saving to core data")
            }
        } else {
            //TODO: to alert user that he doesnt have enough money in the wallet
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
        guard let safeStock = stock else { return }
        
        let name = safeStock.price.shortName ?? ""
        let stockPrice = "\(safeStock.price.regularMarketOpen.raw!)"
        let stockSymbol = safeStock.symbol
        viewDelegate?.showStockInfo(fullName: name, price: stockPrice, symbol: stockSymbol)
    }
}
