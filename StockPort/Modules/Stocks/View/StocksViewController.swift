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
        self.hideKeyboardWhenTappedAround()
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
            guard let sections = presenter.filtredSections else { return }
            viewController.stock = sections[indexPath.section].stocks[indexPath.row]
            print(viewController.stock)
        }
    }
}



//MARK:- Extensions
//MARK:- UITableViewDataSource
extension StocksViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.filtredSections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.filtredSections?[section].stocks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.cellId) as? StockCell else { return UITableViewCell()}
        let stock = presenter.filtredSections?[indexPath.section].stocks[indexPath.row]
        cell.configureCell(with: stock, presenter: presenter)
        return cell
    }
}

//MARK:- UITableViewDelegate
extension StocksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sections = presenter.filtredSections else { return 0 }
        return sections[indexPath.section].isExpanded == true ? 50 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderFooterView()
        guard let sections = presenter.filtredSections else { return header}
        header.setHeaderFooterView(title: sections[section].name, section: section, delegate: self)
        return header
    }
}

//MARK:- UISearchBarDelegate
extension StocksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filterSections(with: searchText)
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

//MARK:- UISearchBarDelegate
extension StocksViewController: ExpandableHeaderFooterViewDelegate {
    func toggleSection(header: ExpandableHeaderFooterView, section: Int) {
        //presenter.sections[section].isExpanded = !s{ections[section].isExpanded
        //guard var sections = presenter.sections else { return }
        if !(presenter.filtredSections == nil) {
            presenter.filtredSections![section].isExpanded = !presenter.filtredSections![section].isExpanded
            tableView.beginUpdates()
            for index in 0..<(presenter.filtredSections?[section].stocks.count)! {
                tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .fade)
            }
            tableView.endUpdates()
        }
    }
}
