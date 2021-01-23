//
//  CurrencyCell.swift
//  StockPort
//
//  Created by ArturZaharov on 23.01.2021.
//

import UIKit

class CurrencyCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var currencyCode: UILabel!
    @IBOutlet weak var name: UILabel!
    
    let cellId = "currencyCell"
    
    public func configureCell(with currency: Currency){
        if let safeSymbol = currency.symbol {
            symbol.text = safeSymbol
        } else {
            symbol.text = " "
        }
        
        currencyCode.text = currency.currencyCode
        
        if let safeName = currency.name {
            name.text = safeName
        } else {
            name.text = " "
        }
        
    }

}
