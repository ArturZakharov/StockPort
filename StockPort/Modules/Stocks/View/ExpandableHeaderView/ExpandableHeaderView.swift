//
//  ExpandableHeaderView.swift
//  StockPort
//
//  Created by ArturZaharov on 25.04.2021.
//

import UIKit

protocol ExpandableHeaderFooterViewDelegate {
    func toggleSection(header: ExpandableHeaderFooterView, section: Int)
}

class ExpandableHeaderFooterView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    private var delegate: ExpandableHeaderFooterViewDelegate?
    private var section: Int!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        contentView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderFooterView
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func setHeaderFooterView(title: String, section: Int, delegate: ExpandableHeaderFooterViewDelegate) {
        textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }
}

