//
//  DownloadFile.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 01.07.2022.
//

import Foundation
import FilesProvider

enum DownloadFileStatus {
    case unknown, downloading, complate, error
}

struct DownloadFile {
    var file: FileObject?
    var status: DownloadFileStatus = .unknown
    var localUrl: URL?
}

extension DownloadFile: Equatable {
    static func ==(lhs: DownloadFile, rhs: DownloadFile) -> Bool {
        return lhs.file?.path == rhs.file?.path
    }
}
