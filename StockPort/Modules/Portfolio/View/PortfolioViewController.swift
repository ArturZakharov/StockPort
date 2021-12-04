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
    @IBOutlet weak var arrowImage: UIImageView!
    
    //MARK:- Properties
    private let presenter = PortfolioPresenter(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    
    //MARK:- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        userStocksTableView.showActivityIndicator()
        currencyTableView.showActivityIndicator()
        presenter.setViewDelegate(portfolioViewDelegate: self)
        configureButtons()
       // configureArrow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = userStocksTableView.indexPathForSelectedRow {
            userStocksTableView.deselectRow(at: selectedIndexPath, animated: true)
            configureButtons()
        }
        presenter.getWalletBalance()
        presenter.refreshData()
        userStocksTableView.reloadData()
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
    
//    private func configureArrow(){
//        presenter.getArrowStatus()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? StocksDetailsViewController {
            viewController.buyButtonShow = false
            guard let indexPath = userStocksTableView.indexPathForSelectedRow else { return }
            viewController.stock = presenter.stocks[indexPath.row]
        }
    }
    
    deinit {
        presenter.saveUserStocksSum()
    }
}

//MARK:- Extensions
//MARK:- UITableViewDataSource
extension PortfolioViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case currencyTableView:
            return presenter.filterdCurrency.count
        case userStocksTableView:
            return presenter.userStocks.count
        default:
            print("Something wrong with numberOfRows")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case currencyTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.cellID) as? CurrencyCell else { return UITableViewCell() }
            cell.configureCell(with: presenter.filterdCurrency[indexPath.row])
            return cell
        case userStocksTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchasedStockCell.cellID) as? PurchasedStockCell else { return UITableViewCell() }
//            let i = indexPath.row
//            cell.configureCell(with: presenter.purchasedStocks[i], stockData: presenter.stocks[i])
            cell.configureCell(with: presenter, index: indexPath.row)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK:- UITableViewDelegate
extension PortfolioViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case userStocksTableView:
            sellButton.isEnabled = true
            sellButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case currencyTableView:
            presenter.currencyOfTheWalletChanged(to: presenter.filterdCurrency[indexPath.row])
            presenter.refreshData()
            currencyTableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
}

//MARK:- UISearchBarDelegate
extension PortfolioViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filterCurrencies(with: searchText)
    }
}


extension PortfolioViewController: PortfolioViewDelegate{
    func showStatusArrow(arrowStatus: ArrowStatus) {
        DispatchQueue.main.async {
            switch arrowStatus {
            case .green:
                print("green")
                self.arrowImage.image = UIImage(named: "arrow_up_green")
            case .red:
                print("red")
                self.arrowImage.image = UIImage(named: "arrow_down_red")
            case .normal:
                print("normal")
                self.arrowImage.image = UIImage(named: "arrow_up_gray")
            default:
                break
            }
        }
    }
    

    func showCurrentWalletBalance(balance: String) {
        balanceLabel.text = balance
    }
    
    func showCurrency() {
        DispatchQueue.main.async {
            self.currencyTableView.stopActivityIndicator()
            self.currencyTableView.reloadData()
        }
    }
    
    func showPurchasedStoks(){
        DispatchQueue.main.async {
            self.userStocksTableView.stopActivityIndicator()
            self.userStocksTableView.reloadData()
        }
    }
}
