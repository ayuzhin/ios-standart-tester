//
//  UITableViewCellExtensions.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 02.07.2022.
//

import UIKit

// MARK: - Methods

extension UITableViewCell {
    
    static func createForTableView(_ tableView: UITableView) -> UITableViewCell? {
        let className = String(describing: self)

        var cell: UITableViewCell?

        cell = tableView.dequeueReusableCell(withIdentifier: className)

        if cell == nil {
            cell = Bundle.main.loadNibNamed(className, owner: self, options: nil)?.first as? UITableViewCell
            let cellNib = UINib(nibName: className, bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: className)
        }

        return cell
    }
}
