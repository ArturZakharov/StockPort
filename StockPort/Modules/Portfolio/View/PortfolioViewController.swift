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
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    //MARK:- Properties
    let ser = CurrencyService.shared
    var currencyValueArray: CurrencyValue? {
        didSet{ getCurrency() }
    }
    var currencyValueElement: CurrencyData?

    var currency = [Currency]() {
        didSet{ filterdCurrency = currency }
    }
    var filterdCurrency = [Currency]()
    
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        
        ser.getCurrencyValue { value in
            self.currencyValueArray = value
        } 
    }
    
    @IBAction func buyButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func sellButtonTapped(_ sender: UIButton) {
    }
    
    private func configureButtons(){
        buyButton.layer.cornerRadius = 15
        sellButton.layer.cornerRadius = 15
    }
}

//MARK:- Extensions
//MARK:- UITableViewDataSource
extension PortfolioViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case currencyTableView:
            return filterdCurrency.count
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
            cell.configureCell(with: filterdCurrency[indexPath.row])
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
            for (key, value) in currencyValueArray.response.rates{
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
