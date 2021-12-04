//
//  PortfolioPresenter.swift
//  StockPort
//
//  Created by ArturZaharov on 20.03.2021.
//

import Foundation
import CoreData

enum ArrowStatus {
    case green
    case red
    case normal
}
protocol PortfolioViewDelegate: AnyObject {
    func showCurrentWalletBalance(balance: String)
    func showCurrency()
    func showPurchasedStoks()
    func showStatusArrow(arrowStatus: ArrowStatus)
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
    //check
    var purchasedStocks = [PurchasedStock]()
    var user = [User]()
    var userID: String?
    var stocks = [Stock]()
    var userStocks = [UsersStocks](){
        didSet{
            setUserPurchasedStoks()
            calculateAllMoney()
            if !arrowStatusWasTriggered{
                getArrowStatus()
            }
        }
    }
    var arrowStatusWasTriggered = false
           
    private let moneyBuilder = MoneyBuilder()
    
    //MARK:- Functions
    init(context: NSManagedObjectContext) {
        self.context = context
        // getCurrencyData()
        //getUserPurchasedStocks()
        userID = userDefaults.string(forKey: "currentUserID")
    }
    
    func setViewDelegate(portfolioViewDelegate: PortfolioViewDelegate){
        viewDelegate = portfolioViewDelegate
        getCurrencyData()
    }
    
    func getWalletBalance(){
        guard let userId = userID else { return }
        let walletName = "wallet \(userId)"
        if userDefaults.object(forKey: walletName) == nil {
            userDefaults.set(10000.00, forKey: walletName)
        }
        let money = userDefaults.double(forKey: walletName)
        viewDelegate?.showCurrentWalletBalance(balance: moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: money))
    }
    
    func getArrowStatus(){
        guard let userId = userID else { return }
        let key = "userStoksPriceSum \(userId)"
        if userDefaults.object(forKey: key) == nil {
            viewDelegate?.showStatusArrow(arrowStatus: .normal)
            arrowStatusWasTriggered = true
        } else {
            if userStocks.count == purchasedStocks.count && purchasedStocks.count != 0 {
                
                let lastStocksPrice = userDefaults.double(forKey: key)
                let currentStocksPrice = getProfit()
                let difference = lastStocksPrice - currentStocksPrice
                
                switch difference {
                case ..<0:
                    viewDelegate?.showStatusArrow(arrowStatus: .green)
                    arrowStatusWasTriggered = true
                case 0...:
                    viewDelegate?.showStatusArrow(arrowStatus: .red)
                    arrowStatusWasTriggered = true
                default:
                    break
                }
            }
        }
    }
    
    func saveUserStocksSum(){
        guard let userId = userID else { return }
        let key = "userStoksPriceSum \(userId)"
        let sum = getProfit()
        userDefaults.set(sum, forKey: key)
    }
    
    func getCurrencyData(){
        currencyService.getCurrencyValue { value in
            self.getCurrency(currencyValue: value)
        }
    }
    
    func getProfit() -> Double {
        var sum = 0.0
        for stock in userStocks{
            sum += stock.countity * stock.price
        }
        return sum
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
        guard let userID = userID else { return }
        do {
            let request = User.fetchRequest() as NSFetchRequest<User>
            let predicate = NSPredicate(format: "userId CONTAINS '\(userID)'")
            request.predicate = predicate
            user = try context.fetch(request)
        } catch  {
            //TODO: problem fetching data
            print("Error fetching users from CoreData")
        }
        
        if let stocks = user[0].stocks {
            StockService.shared.cancelPreviousRequest()
            purchasedStocks = stocks.allObjects as! [PurchasedStock]
            
            for item in purchasedStocks {
                StockService.shared.getStock(stockSymbol: item.stockSymbol) { stockData in
                    self.stocks.append(stockData)
                    if let price = stockData.price.regularMarketOpen.raw {
                        self.userStocks.append(UsersStocks(symbol: item.stockSymbol, countity: item.countity, price: price))
                    }
                }
            }
        }
    }
    
    func refreshData(){
        userStocks = [UsersStocks]()
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
    
//    func calculateAllMoney(){
//        if purchasedStocks.count != 0 && purchasedStocks.count == stocks.count {
//            var sum = 0.0
//            for (index, _) in stocks.enumerated() {
//                if let price = stocks[index].price.regularMarketOpen.raw {
//                    let result = price * Double(purchasedStocks[index].countity)
//                    sum += result
//                }
//            }
//            guard let userId = userID else { return }
//            let walletSum = userDefaults.double(forKey: "wallet \(userId)")
//            sum += walletSum
//            print(sum)
//        }
//    }
    
    func calculateAllMoney(){
        if userStocks.count != 0 && purchasedStocks.count == stocks.count {
            var sum = 0.0
            for stock in userStocks {
                let result = stock.price * stock.countity
                    sum += result
            }
            guard let userId = userID else { return }
            let walletSum = userDefaults.double(forKey: "wallet \(userId)")
            sum += walletSum
            print(sum)
        }
    }
}
