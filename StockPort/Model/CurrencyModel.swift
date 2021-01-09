//
//  CurrencyModel.swift
//  StockPort
//
//  Created by ArturZaharov on 05.01.2021.
//

import Foundation

// MARK: - CurrencyValue
struct Currency: Codable {
    let name, symbolNative, code: String

    enum CodingKeys: String, CodingKey {
        case name
        case symbolNative = "symbol_native"
        case code
    }
}


struct CurrencyValue: Codable {
    let currencyRates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case currencyRates = "currency_rates"
    }
}
