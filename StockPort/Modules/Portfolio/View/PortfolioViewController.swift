//
//  PortfolioViewController.swift
//  StockPort
//
//  Created by ArturZaharov on 09.01.2021.
//

import UIKit

class PortfolioViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var balanceLabel: UILabel!
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
    
    let userDefaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var purchasedStocks: [PurchasedStock]?
    var stocks = [Stock]() {
        didSet{ DispatchQueue.main.async {
            self.userStocksTableView.reloadData()
            }
        }
    }
    
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        configurePage()
        fetchData()
        
        // paused because of limited api calls
//        ser.getCurrencyValue { value in
//            self.currencyValueArray = value
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = userStocksTableView.indexPathForSelectedRow {
            userStocksTableView.deselectRow(at: selectedIndexPath, animated: animated)
            configureButtons()
        }
    }
    
    @IBAction func sellButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueFromSellButton", sender: nil)
    }
    
    private func configureButtons(){
        buyButton.layer.cornerRadius = 15
        sellButton.layer.cornerRadius = 15
        sellButton.isEnabled = false
        sellButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    private func configurePage(){
        if userDefaults.object(forKey: "wallet") == nil {
            userDefaults.set(10000.00, forKey: "wallet")
        }
        let balance = userDefaults.double(forKey: "wallet").rounded(toPlaces: 2)
        balanceLabel.text = "Balance: \(balance)$"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? StocksDetailsViewController {
            viewController.buyButtonShow = false
            guard let indexPath = userStocksTableView.indexPathForSelectedRow else { return }
            viewController.stock = stocks[indexPath.row]
        }
        
    }
    
//    func fetchData(){
//
//        do {
//            purchasedStocks = try context.fetch(PurchasedStock.fetchRequest())
//            DispatchQueue.main.async {
//                self.userStocksTableView.reloadData()
//            }
//        } catch  {
//            //TODO: problem fetching data
//            print("PROOOOOOOOOBLEM")
//        }
//    }
    
    func fetchData(){
        do {
            purchasedStocks = try context.fetch(PurchasedStock.fetchRequest())
        } catch  {
            //TODO: problem fetching data
            print("PROOOOOOOOOBLEM")
        }
        
        guard let purchasedStocks = purchasedStocks else { return }
        for stock in purchasedStocks{
            StockService.shared.getStock(stockSymbol: stock.stockASymbol) { stockData in
                self.stocks.append(stockData)
            }
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

//MARK:- Extensions
//MARK:- UITableViewDataSource
extension PortfolioViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case currencyTableView:
            return filterdCurrency.count
        case userStocksTableView:
            return stocks.count
        default:
            print("Something wrong with numberOfRows")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case currencyTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.cellID) as? CurrencyCell else { return UITableViewCell() }
            cell.configureCell(with: filterdCurrency[indexPath.row])
            return cell
        case userStocksTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchasedStockCell.cellID) as? PurchasedStockCell, let purchasedStocks = purchasedStocks else { return UITableViewCell() }
            let i = indexPath.row
            cell.configureCell(with: purchasedStocks[i], stockData: stocks[i])
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK:- UITableViewDataSource
extension PortfolioViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case userStocksTableView:
            sellButton.isEnabled = true
            sellButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        default:
            break
        }
    }
}

//MARK:- UISearchBarDelegate
extension PortfolioViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty && searchText.count > 0 && searchText.count < 4 {
            filterdCurrency = currency.filter({
                $0.currencyCode.lowercased().contains(searchText.lowercased())})
        } else if searchText.count >= 4 {
            filterdCurrency = currency.filter({
                $0.name?.lowercased().contains(searchText.lowercased()) ?? false })
        } else {
            filterdCurrency = currency
        }
        
        currencyTableView.reloadData()
    }
}
