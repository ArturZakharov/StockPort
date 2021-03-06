//
//  purchasedStockCell.swift
//  StockPort
//
//  Created by ArturZaharov on 09.03.2021.
//

import UIKit

class PurchasedStockCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var stockFullNamelabel: UILabel!
    @IBOutlet weak var stockPriceLabel: UILabel!
    @IBOutlet weak var stockCountityLabel: UILabel!
    @IBOutlet weak var priceOfPurchasedShares: UILabel!
    
    //MARK:- Properties
    public static let cellID = "purchasedStockCell"
    
    //MARK:- Functions
//    public func configureCell(with purchasedStock: PurchasedStock, stockData: Stock){
//        stockCountityLabel.text = "\(Int(purchasedStock.countity))"
//        stockFullNamelabel.text = purchasedStock.stockASymbol
//        stockPriceLabel.text = "\(stockData.price.regularMarketOpen.fmt ?? "") $"
//
//        if let price = stockData.price.regularMarketOpen.raw {
//            priceOfPurchasedShares.text = "\(price * purchasedStock.countity)"
//        }
//    }
    
//    public func configureCell(with presenter: PortfolioPresenter, index: Int){
//        let purchasedStock = presenter.purchasedStocks[index]
//        stockCountityLabel.text = "\(Int(purchasedStock.countity))"
//        stockFullNamelabel.text = purchasedStock.stockSymbol
//
//        let stockData = presenter.stocks[index]
//        if let price = stockData.price.regularMarketOpen.raw {
//            priceOfPurchasedShares.text = presenter.getMoneyInCorrectForm(money: price * purchasedStock.countity)
//            stockPriceLabel.text = presenter.getMoneyInCorrectForm(money: price)
//        }
//    }
    
    public func configureCell(with presenter: PortfolioPresenter, index: Int){
        let purchasedStock = presenter.userStocks[index]
        stockCountityLabel.text = "\(Int(purchasedStock.countity))"
        stockFullNamelabel.text = purchasedStock.symbol
        
        priceOfPurchasedShares.text = presenter.getMoneyInCorrectForm(money: purchasedStock.price * purchasedStock.countity)
        stockPriceLabel.text = presenter.getMoneyInCorrectForm(money: purchasedStock.price)
        
    }
}
