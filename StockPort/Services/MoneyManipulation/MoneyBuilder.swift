//
//  MoneyBuilder.swift
//  StockPort
//
//  Created by ArturZaharov on 17.04.2021.
//

import Foundation

struct MoneyBuilder {
    let userDefaults = UserDefaults.standard
    
    func getMoneyInCorrectCurrency(moneyAmount: Double) -> String{
        if userDefaults.object(forKey: "symbol") == nil && userDefaults.object(forKey: "currencyValue") == nil {
            return "\(moneyAmount.rounded(toPlaces: 2)) $"
        } else {
            let currencyValue = userDefaults.double(forKey: "currencyValue")
            guard let symbol = userDefaults.string(forKey: "symbol") else { return "error accured" }
            let balanceInCurrentCurrency = (moneyAmount * currencyValue).rounded(toPlaces: 2)
            return "\(balanceInCurrentCurrency) \(symbol)"
        }
    }
}
