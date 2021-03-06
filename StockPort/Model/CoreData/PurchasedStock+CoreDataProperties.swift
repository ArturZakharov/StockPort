//
//  PurchasedStock+CoreDataProperties.swift
//  StockPort
//
//  Created by ArturZaharov on 09.03.2021.
//
//

import Foundation
import CoreData


extension PurchasedStock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PurchasedStock> {
        return NSFetchRequest<PurchasedStock>(entityName: "PurchasedStock")
    }

    @NSManaged public var countity: Double
    @NSManaged public var stockSymbol: String
    @NSManaged public var owner: User?

}

extension PurchasedStock : Identifiable {

}
