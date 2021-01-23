//
//  PortfolioViewController.swift
//  StockPort
//
//  Created by ArturZaharov on 09.01.2021.
//

import UIKit

class PortfolioViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var currencyTableView: UITableView!
    @IBOutlet weak var userStocksTableView: UITableView!
    
    //MARK:- Properties
    let ser = CurrencyService.shared
    var currencyValueArray: CurrencyValue? {
        didSet{ getCurrency() }
    }
    var currencyValueElement: CurrencyData?
//    var currency = [Currency]() {
//        didSet{ DispatchQueue.main.async {
//            self.currencyTableView.reloadData()
//        } }
//    }
    var currency = [Currency]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ser.getCurrencyValue { value in
            self.currencyValueArray = value
        }
        
       
    }
}

extension PortfolioViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case currencyTableView:
            return currency.count
        case userStocksTableView:
            return 1
        default:
            print("Something wrong with numberOfRows")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case currencyTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell") as? CurrencyCell else { return UITableViewCell() }
            cell.configureCell(with: currency[indexPath.row])
            return cell
        case userStocksTableView:
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    //func that get symbols for currency
    func getCurrency(){
        ser.getCurrencySimbols { valueElement in
            self.currencyValueElement = valueElement
            guard let currencyValueElement = self.currencyValueElement else {return}
            guard let currencyValueArray = self.currencyValueArray else {return}
            for (key, value) in currencyValueArray.currencyRates{
                let currencyElement = Currency(name:currencyValueElement.currency[key]?.name,
                                               currencyCode: key,
                                        symbol: currencyValueElement.currency[key]?.symbol,
                                        value: value)
                self.currency.append(currencyElement)
            }
            DispatchQueue.main.async {
                        self.currencyTableView.reloadData()
                    }
        }
    }
}
