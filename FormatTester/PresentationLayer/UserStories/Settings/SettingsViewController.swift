//
//  SettingsViewController.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 02.07.2022.
//

import UIKit

class SettingsViewController: BaseViewController {

    typealias SettingsSegment = (title: String?, items: [SettingInputTextViewCellViewModel])
    
    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    var serverAddress: String? {
        get { UserDefaults.standard.string(forKey: Const.SettingsKeys.serverAddress) }
        set { UserDefaults.standard.set(newValue, forKey: Const.SettingsKeys.serverAddress) }
    }
    
    var serverLogin: String? {
        get { UserDefaults.standard.string(forKey: Const.SettingsKeys.serverLogin) }
        set { UserDefaults.standard.set(newValue, forKey: Const.SettingsKeys.serverLogin) }
    }
    
    var serverPassword: String? {
        get { UserDefaults.standard.string(forKey: Const.SettingsKeys.serverPassword) }
        set { UserDefaults.standard.set(newValue, forKey: Const.SettingsKeys.serverPassword) }
    }
    
    var tableData: [SettingsSegment] = []
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        
        build()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.fillToSuperview()
        tableView.reloadData()
    }
    
    private func configureNavigationBar() {
        title = "Settings"
    }
    
    private func build() {
        tableData = [
            SettingsSegment(
                title: "Server",
                items: [
                    SettingInputTextViewCellViewModel(
                        caption: "Address",
                        value: serverAddress,
                        valueChanged: { [weak self] address in
                            self?.serverAddress = address
                        }
                    ),
                    SettingInputTextViewCellViewModel(
                        caption: "Login",
                        value: serverLogin,
                        valueChanged: { [weak self] login in
                            self?.serverLogin = login
                        }
                    ),
                    SettingInputTextViewCellViewModel(
                        caption: "Password",
                        value: serverPassword,
                        valueChanged: { [weak self] password in
                            self?.serverPassword = password
                        }
                    ),
                ]
            )
        ]
        
        tableView.reloadData()
    }
    
}

// MARK: - Tableview sections

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = SettingInputTextViewCell.createForTableView(tableView) as? SettingInputTextViewCell else { return UITableViewCell() }
        cell.viewModel = tableData[indexPath.section].items[indexPath.row]
        return cell
    }
    
}
