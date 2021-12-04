//
//  User+CoreDataProperties.swift
//  StockPort
//
//  Created by ArturZaharov on 05.06.2021.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userId: String
    @NSManaged public var stocks: NSSet?

}

// MARK: Generated accessors for stocks
extension User {

    @objc(addStocksObject:)
    @NSManaged public func addToStocks(_ value: PurchasedStock)

    @objc(removeStocksObject:)
    @NSManaged public func removeFromStocks(_ value: PurchasedStock)

    @objc(addStocks:)
    @NSManaged public func addToStocks(_ values: NSSet)

    @objc(removeStocks:)
    @NSManaged public func removeFromStocks(_ values: NSSet)

}

extension User : Identifiable {

}
