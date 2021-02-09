//
//  Stock.swift
//  StockPort
//
//  Created by ArturZaharov on 09.02.2021.
//

import Foundation

// MARK: - CurrencyValue
struct Stock: Codable {
    let summaryProfile: SummaryProfile
    let symbol: String
    let price: Price
}

// MARK: - Price
struct Price: Codable {
    let regularMarketOpen: DividendDate
    let shortName: String
}

// MARK: - SummaryProfile
struct SummaryProfile: Codable {
    let industry: String
    let sector: String
}

// MARK: - DividendDate
struct DividendDate: Codable {
    let raw: Double
    let fmt: String
}
