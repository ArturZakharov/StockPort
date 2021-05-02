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
    var stocks: [Stock]? {
        didSet{createSectionsArray(from: stocks!)}}
    let userDefaults = UserDefaults.standard
    private let moneyBuilder = MoneyBuilder()
    var sections: [Section]?
    
    //MARK:- Functions
    func setViewDelegate(stocksViewDelegate: StocksViewDelegate){
        self.viewDelegate = stocksViewDelegate
    }
    
    func getStocks(){
        StockService.shared.getStocksNames { companiesNames in
//            StockService.shared.getStock(stockSymbol: companiesNames[0].symbol) { stockData in
//                if stockData.price.regularMarketOpen.fmt != nil {
//                    self.stocks = [stockData]
//                    self.viewDelegate?.showStocks()
//                }
//            }
           // only for test purpes
            self.stocks = [Stock]()
                        for i in 0...2 {
                            StockService.shared.getStock(stockSymbol: companiesNames[i].symbol) { stockData in
                                if stockData.price.regularMarketOpen.fmt != nil {
                                    self.stocks?.append(stockData)
                                }
                            }
                        }
            //working code
//            self.stocks = [Stock]()
//                        for company in companiesNames {
//                            StockService.shared.getStock(stockSymbol: company.symbol) { stockData in
//                                if stockData.price.regularMarketOpen.fmt != nil {
//                                    self.stocks?.append(stockData)
//                                    
//                                }
//                                self.viewDelegate?.showStocks()
//                            }
//                        }
        }
    }
    
    func getMoneyInCorrectForm(money: Double) -> String {
        return moneyBuilder.getMoneyInCorrectCurrency(moneyAmount: money)
    }
    
    private func createSectionsArray(from stocks: [Stock]){
        var industryDictionary = [String: [Stock]]()
        
        for stock in stocks {
            guard let industry = stock.summaryProfile.industry else { return }
            if !industryDictionary.contains(where: {$0.key == stock.summaryProfile.industry}) {
                industryDictionary[industry] = [stock]
            } else {
                industryDictionary[industry]! += [stock]
            }
        }
        
        sections = [Section]()
        
        for element in industryDictionary {
            let sortedStocks = element.value.sorted { $0.price.shortName < $1.price.shortName }
            sections?.append(Section(name: element.key, stocks: sortedStocks, isExpanded: false))
        }
        
        sections = sections?.sorted{ $0.name < $1.name }
        self.viewDelegate?.showStocks()
    }
}
