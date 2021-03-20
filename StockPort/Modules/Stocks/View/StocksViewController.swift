//
//  StocksViewController.swift
//  StockPort
//
//  Created by ArturZaharov on 09.02.2021.
//

import UIKit

class StocksViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var stocks = [Stock]() {
        didSet{ DispatchQueue.main.async {
            self.tableView.reloadData()
            }
        }
    }
    
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getStocks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    func getStocks(){
        StockService.shared.getStocksNames { companiesNames in
            StockService.shared.getStock(stockSymbol: companiesNames[0].symbol) { stockData in
                if stockData.price.regularMarketOpen.fmt != nil {
                    self.stocks.append(stockData)
                }
            }
            //only for test purpes
//            for i in 0...2 {
//                StockService.shared.getStock(stockSymbol: companiesNames[i].symbol) { stockData in
//                    if stockData.price.regularMarketOpen.fmt != nil {
//                        self.stocks.append(stockData)
//                    }
//                }
//            }
            //working code
//            for company in companiesNames {
//                StockService.shared.getStock(stockSymbol: company.symbol) { stockData in
//                    if stockData.price.regularMarketOpen.fmt != nil {
//                        self.stocks.append(stockData)
//                    }
//
//                    print(stockData.price.regularMarketOpen.fmt)
//                }
//            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? StocksDetailsViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            viewController.stock = stocks[indexPath.row]
        }
    }
}



//MARK:- Extensions
//MARK:- UITableViewDataSource
extension StocksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.cellId) as? StockCell else { return UITableViewCell()}
        
        cell.configureCell(with: stocks[indexPath.row])
        
        return cell
    }
    
    
}
    
//MARK:- UISearchBarDelegate
extension StocksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //TODO:-
    }
}
