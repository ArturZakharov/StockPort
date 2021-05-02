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
    private let presenter = StocksPresenter()
    
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setViewDelegate(stocksViewDelegate: self)
        tableView.showActivityIndicator()
        //getStocks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? StocksDetailsViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            viewController.stock = presenter.stocks?[indexPath.row]
        }
    }
}



//MARK:- Extensions
//MARK:- UITableViewDataSource
extension StocksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.stocks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.cellId) as? StockCell else { return UITableViewCell()}
        let stock = presenter.stocks?[indexPath.row]
        //cell.configureCell(with: stock)
        cell.configureCell(with: presenter, index: indexPath.row)
        return cell
    }
}

//MARK:- UISearchBarDelegate
extension StocksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //TODO:-
    }
}

extension StocksViewController: StocksViewDelegate {
    func showStocks() {
        DispatchQueue.main.async {
            self.tableView.stopActivityIndicator()
            self.tableView.reloadData()
            
        }
    }
}
