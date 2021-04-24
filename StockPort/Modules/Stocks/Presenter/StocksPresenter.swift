//
//  StocksPresenter.swift
//  StockPort
//
//  Created by ArturZaharov on 01.04.2021.
//

import Foundation

protocol StocksViewDelegate: class{
    func showStocks()
}

class StocksPresenter {
    
    //MARK:- Properties
    private weak var viewDelegate: StocksViewDelegate? { didSet{ getStocks() } }
    var stocks: [Stock]?
    let userDefaults = UserDefaults.standard
    private let moneyBuilder = MoneyBuilder()
    
    //MARK:- Functions
    func setViewDelegate(stocksViewDelegate: StocksViewDelegate){
        self.viewDelegate = stocksViewDelegate
    }
    
    func getStocks(){
        StockService.shared.getStocksNames { companiesNames in
            StockService.shared.getStock(stockSymbol: companiesNames[0].symbol) { stockData in
                if stockData.price.regularMarketOpen.fmt != nil {
                    self.stocks = [stockData]
                    self.viewDelegate?.showStocks()
                }
            }
            //only for test purpes
            //            for i in 0...2 {
            //                StockService.shared.getStock(stockSymbol: companiesNames[i].symbol) { stockData in
            //                    if stockData.price.regularMarketOpen.fmt != nil {
            //                        self.stocks.append(stockData)
            //                    }
            //                }
            //            }
            //working code
            //            for company in companiesNames {
            //                StockService.shared.getStock(stockSymbol: company.symbol) { stockData in
            //                    if stockData.price.regularMarketOpen.fmt != nil {
            //                        self.stocks.append(stockData)
            //                    }
            //
            //                    print(stockData.price.regularMarketOpen.fmt)
            //                }
            //            }
        }
    }
    
    func getMoneyInCorrectForm(money: Double) -> String {
        return moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: money)
    }
}
