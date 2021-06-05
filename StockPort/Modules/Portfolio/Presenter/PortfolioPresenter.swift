//
//  PortfolioPresenter.swift
//  StockPort
//
//  Created by ArturZaharov on 20.03.2021.
//

import Foundation
import CoreData

protocol PortfolioViewDelegate: AnyObject {
    func showCurrentWalletBalance(balance: String)
    func showCurrency()
    func showPurchasedStoks()
}

class PortfolioPresenter{
    
    //MARK:- Properties
    let currencyService = CurrencyService.shared
    var currencies = [Currency]() { didSet{ filterdCurrency = currencies } }
    var filterdCurrency = [Currency]()
    var choosedCurrencyForWallet: Currency?
    
    private weak var viewDelegate: PortfolioViewDelegate?{
        didSet{ getWalletBalance() }
    }
    let userDefaults = UserDefaults.standard
    private var context: NSManagedObjectContext
    var purchasedStocks = [PurchasedStock]()
    var stocks = [Stock](){
        didSet{ setUserPurchasedStoks() }
    }
    private let moneyBuilder = MoneyBuilder()
    
    //MARK:- Functions
    init(context: NSManagedObjectContext) {
        self.context = context
        // getCurrencyData()
        //getUserPurchasedStocks()
    }
    
    func setViewDelegate(portfolioViewDelegate: PortfolioViewDelegate){
        viewDelegate = portfolioViewDelegate
        getCurrencyData()
    }
    
    func getWalletBalance(){
        if userDefaults.object(forKey: "wallet") == nil {
            userDefaults.set(10000.00, forKey: "wallet")
        }
        let money = userDefaults.double(forKey: "wallet")
        viewDelegate?.showCurrentWalletBalance(balance: moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: money))
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
            StockService.shared.cancelPreviousRequest()
            for item in purchasedStocks{
                StockService.shared.getStock(stockSymbol: item.stockSymbol) { stockData in
                    self.stocks.append(stockData)
                }
            }
        }
    }
    
    func refreshData(){
        stocks = [Stock]()
        purchasedStocks = [PurchasedStock]()
        getUserPurchasedStocks()
        getWalletBalance()
    }
    
    private func setUserPurchasedStoks(){
        viewDelegate?.showPurchasedStoks()
    }
    
    func currencyOfTheWalletChanged(to currency: Currency){
        choosedCurrencyForWallet = currency
        userDefaults.set(currency.symbol, forKey: "symbol")
        userDefaults.set(currency.value, forKey: "currencyValue")
    }
    
    func getMoneyInCorrectForm(money: Double) -> String {
        return moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: money)
    }
    
    func filterCurrencies(with searchText: String){
        if !searchText.isEmpty && searchText.count > 0 && searchText.count < 4 {
            filterdCurrency = currencies.filter({
                $0.currencyCode.lowercased().contains(searchText.lowercased())})
            if filterdCurrency.count == 0 {
                filterdCurrency = currencies.filter({
                    $0.name?.lowercased().contains(searchText.lowercased()) ?? false })
            }
        } else if searchText.count >= 4 {
            filterdCurrency = currencies.filter({
                $0.name?.lowercased().contains(searchText.lowercased()) ?? false })
        } else {
           filterdCurrency = currencies
        }

        viewDelegate?.showCurrency()
    }
}
