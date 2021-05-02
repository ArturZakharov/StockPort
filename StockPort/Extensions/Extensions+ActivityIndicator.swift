//
//  Indicator.swift
//  StockPort
//
//  Created by ArturZaharov on 01.05.2021.
//

import UIKit

extension UIView {
    static let loadingViewTag = 1938123987
    
    func showActivityIndicator(style: UIActivityIndicatorView.Style = .large) {
        var loading = viewWithTag(UIImageView.loadingViewTag) as? UIActivityIndicatorView
            if loading == nil {
                loading = UIActivityIndicatorView(style: style)
            }
        
            loading?.translatesAutoresizingMaskIntoConstraints = false
            loading!.startAnimating()
            loading!.hidesWhenStopped = true
            loading?.tag = UIView.loadingViewTag
            addSubview(loading!)
          loading?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            loading?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }

    func stopActivityIndicator() {
        let loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
            loading?.stopAnimating()
            loading?.removeFromSuperview()
    }
}
