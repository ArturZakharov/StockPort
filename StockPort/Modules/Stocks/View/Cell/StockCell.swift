//
//  StockCell.swift
//  StockPort
//
//  Created by ArturZaharov on 09.02.2021.
//

import UIKit

class StockCell: UITableViewCell {

    //MARK:-Outlets
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companySymbol: UILabel!
    @IBOutlet weak var stockPrice: UILabel!
    
    //MARK:- Properties
    public static let cellId = "stockCell"
    
    //MARK:- Functions
//    func configureCell(with stock: Stock?){
//        guard let stock = stock else { return }
//        companyName.text = stock.price.shortName
//        companySymbol.text = stock.symbol
//        stockPrice.text = stock.price.regularMarketOpen.fmt
//    }

    func configureCell(with presenter: StocksPresenter, index: Int){
        guard let stock = presenter.stocks?[index] else { return }
        companyName.text = stock.price.shortName
        companySymbol.text = stock.symbol
        guard let price = stock.price.regularMarketOpen.raw else { return }
        stockPrice.text = presenter.getMoneyInCorrectForm(money: price)
    }
}
