//
//  PortfolioPresenter.swift
//  StockPort
//
//  Created by ArturZaharov on 20.03.2021.
//

import Foundation
import CoreData

protocol PortfolioViewDelegate: class {
    func showCurrentWalletBalance(balance: String)
    func showCurrency()
    func showPurchasedStoks()
}

class PortfolioPresenter{
    
    //MARK:- Properties
    let currencyService = CurrencyService.shared
    var currencies = [Currency]() { didSet{ filterdCurrency = currencies } }
    var filterdCurrency = [Currency]()
    
    private weak var viewDelegate: PortfolioViewDelegate?{
        didSet{ getwalletBalance() }
    }
    let userDefaults = UserDefaults.standard
    private var context: NSManagedObjectContext
    var purchasedStocks = [PurchasedStock]()
    var stocks = [Stock](){
        didSet{ setUserPurchasedStoks() }
    }
    
    //MARK:- Functions
    init(context: NSManagedObjectContext) {
        self.context = context
        // getCurrencyData()
        //getUserPurchasedStocks()
    }
    
    func setViewDelegate(portfolioViewDelegate: PortfolioViewDelegate){
        viewDelegate = portfolioViewDelegate
    }
    
    func getwalletBalance(){
        if userDefaults.object(forKey: "wallet") == nil {
            userDefaults.set(10000.00, forKey: "wallet")
        }
        let balance = userDefaults.double(forKey: "wallet").rounded(toPlaces: 2)
        viewDelegate?.showCurrentWalletBalance(balance: "\(balance)")
    }
    
    func getCurrencyData(){
        currencyService.getCurrencyValue { value in
            self.getCurrency(currencyValue: value)
        }
    }
    
    //func that get symbols for currency
    func getCurrency(currencyValue: CurrencyValue?){
        
        currencyService.getCurrencySimbols { valueElement in
            guard let currencyValueElement = valueElement else { return }
            guard let currencyValue = currencyValue else { return }
            for (key, value) in currencyValue.response.rates{
                let name = currencyValueElement.currency[key]?.name
                let symbol = currencyValueElement.currency[key]?.symbol
                if name != nil && symbol != nil {
                    let currencyElement = Currency(name: name,
                                                   currencyCode: key,
                                                   symbol: symbol,
                                                   value: value)
                    self.currencies.append(currencyElement)
                }
            }
            self.viewDelegate?.showCurrency()
        }
    }
    
    private func getUserPurchasedStocks(){
        do {
            purchasedStocks = try context.fetch(PurchasedStock.fetchRequest())
        } catch  {
            //TODO: problem fetching data
            print("PROOOOOOOOOBLEM")
        }
        if purchasedStocks.count != 0 {
            for item in purchasedStocks{
                StockService.shared.getStock(stockSymbol: item.stockASymbol) { stockData in
                    self.stocks.append(stockData)
                }
            }
        }
    }
    
    func refreshData(){
        stocks = [Stock]()
        purchasedStocks = [PurchasedStock]()
        getUserPurchasedStocks()
    }
    
    private func setUserPurchasedStoks(){
        viewDelegate?.showPurchasedStoks()
    }
}
