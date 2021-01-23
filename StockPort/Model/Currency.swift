//
//  CurrencyModel.swift
//  StockPort
//
//  Created by ArturZaharov on 05.01.2021.
//

import Foundation

//MARK:- struct to recive currency value
struct CurrencyValue: Codable {
    let currencyRates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case currencyRates = "currency_rates"
    }
}

//MARK:- structs to get currency symbols
struct CurrencyData: Codable{
    let currency: [String: CurrencyDetails]
}

struct CurrencyDetails: Codable {
    let name: String
    let symbol: String
}

//MARK:- final struct for using in app
struct Currency {
    let name: String?
    let currencyCode: String
    let symbol: String?
    let value: Double
}
