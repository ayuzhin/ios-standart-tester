//
//  SettingInputTextViewCell.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 02.07.2022.
//

import UIKit

struct SettingInputTextViewCellViewModel {
    var caption: String?
    var value: String?
    var valueChanged: SettingInputTextViewCell.InputChangeClousure?
}

class SettingInputTextViewCell: UITableViewCell {

    typealias InputChangeClousure = (String?) -> Void
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    // MARK: - Properties
    
    var viewModel: SettingInputTextViewCellViewModel? {
        didSet {
            nameLabel?.text = viewModel?.caption
            valueTextField?.text = viewModel?.value
            valueChanged = viewModel?.valueChanged
        }
    }
    
    private var valueChanged: InputChangeClousure?
    
    // MARK: - Lifecycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        valueTextField?.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        valueChanged?(textField.text)
    }
        
}
