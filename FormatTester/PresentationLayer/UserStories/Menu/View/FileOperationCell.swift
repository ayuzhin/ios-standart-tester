//
//  FileOperationCell.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 02.07.2022.
//

import UIKit

struct FileOperationCellViewModel {
    var fileInfo: DownloadFile?
    var progress: Float = 0
}

class FileOperationCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - Properties
    
    var viewModel: FileOperationCellViewModel? {
        didSet {
            let status = viewModel?.fileInfo?.status ?? .unknown
            nameLabel?.text = viewModel?.fileInfo?.file?.name
            progressView?.isHidden = status != .downloading
            progressView?.progress = viewModel?.progress ?? 0
            statusImageView?.isHidden = status == .downloading
            
            switch status {
            case .complate:
                statusImageView?.image = UIImage(systemName: "checkmark.circle")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            case .error:
                statusImageView?.image = UIImage(systemName: "xmark.circle")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            default:
                statusImageView?.image = nil
            }
        }
    }
    
    // MARK: - Lifecycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    
}
