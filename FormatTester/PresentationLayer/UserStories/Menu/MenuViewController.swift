//
//  MenuViewController.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 30.06.2022.
//

import UIKit

class MenuViewController: BaseViewController {

    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        $0.startAnimating()
        return $0
    }(UIActivityIndicatorView(style: .medium))
    
    private lazy var errorLabel: UILabel = {
        $0.numberOfLines = -1
        $0.textAlignment = .center
        $0.textColor = .systemGray2
        return $0
    }(UILabel(frame: .zero))
    private lazy var errorView: UIStackView = {
        let imageView = UIImageView(
            image: UIImage(
                systemName: "xmark.circle",
                withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 72, weight: .medium))
            )?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
        )
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 10
        $0.addArrangedSubview(imageView)
        $0.addArrangedSubview(errorLabel)
        return $0
    }(UIStackView(frame: .zero))
    
    private var serverAddress: String {
        return UserDefaults.standard.string(forKey: Const.SettingsKeys.serverAddress) ?? ""
    }
    
    private var serverLogin: String {
        return UserDefaults.standard.string(forKey: Const.SettingsKeys.serverLogin) ?? ""
    }
    
    private var serverPassword: String {
        return UserDefaults.standard.string(forKey: Const.SettingsKeys.serverPassword) ?? ""
    }
    
    private var downloadService: DownloadService?
    private let reloadThrottle = Throttle(minimumDelay: 0.03)
    private var tableData: [FileOperationCellViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureTableView()
        configureActivityView()
        
        displayActivityIndicator()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.fillToSuperview()
        fetchData()
    }
    
    private func configureActivityView() {
        view.addSubview(activityIndicator)
        activityIndicator.anchorCenterSuperview()
    }
    
    private func displayActivityIndicator(show: Bool = true) {
        tableView.isHidden = show
        
        if show {
            view.addSubview(activityIndicator)
            activityIndicator.anchorCenterSuperview()
            activityIndicator.startAnimating()
            displayError(show: false)
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    private func displayError(show: Bool) {
        tableView.isHidden = show
        
        if show {
            view.addSubview(errorView)
            errorView.anchorCenterSuperview()
            errorView.anchor(widthConstant: 200)
            displayActivityIndicator(show: false)
        } else {
            errorView.removeFromSuperview()
        }
    }
    
    private func configureNavigationBar() {
        title = "Testing Files"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .plain,
                target: self,
                action: #selector(openSettings)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "arrow.counterclockwise.circle"),
                style: .plain,
                target: self,
                action: #selector(reloadData)
            ),
        ]
    }
    
    private func initProvider() {
        downloadService = DownloadService(
            server: serverAddress,
            credential: URLCredential(
                user: serverLogin,
                password: serverPassword,
                persistence: .permanent
            )
        )
    }
    
    private func fetchData() {
        initProvider()
        
        displayActivityIndicator()
        
        downloadService?.onBegin = onBeginProcessingItem
        downloadService?.onComplate = onComplateProcessingItem
        downloadService?.onProgress = onProgressItem
        downloadService?.onAllComplation = onAllComplation
        
        tableData = []
        
        downloadService?.fetch { [weak self] error in
            if let error = error {
                self?.errorLabel.text = error.localizedDescription
                self?.displayError(show: true)
            } else {
                self?.displayError(show: false)
                self?.displayActivityIndicator(show: false)
                
                self?.tableData = self?.downloadService?.files.map { FileOperationCellViewModel(fileInfo: $0, progress: 0) } ?? []
                self?.downloadService?.startAll()
            }
        }
    }
    
    private func onBeginProcessingItem(fileInfo: DownloadFile) {
        updateViewModel(for: fileInfo, progress: 0)
    }
    
    private func onComplateProcessingItem(fileInfo: DownloadFile, error: Error?) {
        updateViewModel(for: fileInfo, progress: 100)
    }
    
    private func onProgressItem(fileInfo: DownloadFile, progress: Float) {
        if let index = tableData.firstIndex(where: { $0.fileInfo == fileInfo }) {
            tableData[index] = FileOperationCellViewModel(fileInfo: fileInfo, progress: progress)
        }
        
        reloadThrottle.throttle { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func onAllComplation() {
        let standartTester = StandartTesterServices()
        standartTester.doMagic(with: tableData.compactMap { $0.fileInfo?.localUrl } ) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                let alertController = UIAlertController(
                    title: "Standart Tester",
                    message: "Complation",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alertController, animated: true)
            }
        }
    }
    
    private func updateViewModel(for fileInfo: DownloadFile, progress: Float) {
        if let index = tableData.firstIndex(where: { $0.fileInfo == fileInfo }) {
            tableData[index] = FileOperationCellViewModel(fileInfo: fileInfo, progress: progress)
            
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? FileOperationCell {
                cell.viewModel = tableData[index]
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                tableView.endUpdates()
            }
        }
    }

    @objc
    private func reloadData() {
        fetchData()
    }
    
    @objc
    private func openSettings() {
        navigator.navigate(to: .settings)
    }
}

// MARK: - Tableview sections

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = FileOperationCell.createForTableView(tableView) as? FileOperationCell else { return UITableViewCell() }
        cell.viewModel = tableData[indexPath.row]
        return cell
    }
    
}
