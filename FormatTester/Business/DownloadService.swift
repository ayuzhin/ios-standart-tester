//
//  DownloadService.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 01.07.2022.
//

import Foundation
import FilesProvider

final class DownloadService {
    
    typealias DownloadFileProgress = (object: DownloadFile, downloadProgress: Progress?)
    
    // MARK: - Properties
    
    private var webdavProvider: WebDAVFileProvider?
    private lazy var downloadDirectory = FileManager.default.urls(
        for: .downloadsDirectory,
        in: .userDomainMask).first
    
    private var operations: [DownloadFileProgress] = []
    
    var files: [DownloadFile] {
        operations.map { $0.object }
    }
    
    var onBegin: ((DownloadFile) -> Void)?
    var onComplate: ((DownloadFile, Error?) -> Void)?
    var onProgress: ((DownloadFile, Float) -> Void)?
    var onAllComplation: (() -> Void)?
    
    // MARK: - Lifecycle Methods
    
    convenience init(server: String, credential: URLCredential) {
        self.init()
        
        if let serverUrl = URL(string: server) {
            webdavProvider = WebDAVFileProvider(baseURL: serverUrl, credential: credential)
            webdavProvider?.credentialType = .basic
            webdavProvider?.delegate = self
        }
        
        guard let downloadDirectory = downloadDirectory else { return }
        
        do {
            try FileManager.default.createDirectory(at: downloadDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    public func cleanup() {
        files.forEach { file in
            do {
                if let url = file.localUrl {
                    try FileManager.default.removeItem(at: url)
                }
            } catch {
                print("❗️ ERROR: -\(error)")
            }
        }
        
        operations = []
        cleanupDownloadDirectory()
    }
    
    private func cleanupDownloadDirectory() {
        guard let downloadDirectory = downloadDirectory else { return }
        
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(
                at: downloadDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            for fileUrl in fileUrls {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            print("❗️ ERROR: -\(error)")
        }
    }
    
    public func fetch(complation: @escaping (Error?) -> Void) {
        stopAll()
        cleanup()
        
        webdavProvider?.contentsOfDirectory(path: "") { [weak self] files, error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    complation(error)
                    return
                }
                
                guard let self = self else { return }
                
                self.operations = files
                    .filter { $0.isRegularFile }
                    .map {
                    (object: DownloadFile(
                        file: $0,
                        status: .downloading,
                        localUrl: self.downloadDirectory?.appendingPathComponent($0.name)),
                     downloadProgress: nil
                    )
                }
                
                complation(nil)
            }
        }
    }
    
    public func startAll() {
        guard let downloadDirectory = downloadDirectory else { return }
        
        for var operation in operations {
            onBegin?(operation.object)
            
            operation.downloadProgress = webdavProvider?.copyItem(
                path: operation.object.file?.path ?? "",
                toLocalURL: downloadDirectory.appendingPathComponent(operation.object.file?.name ?? ""),
                completionHandler: { error in
                    //
                }
            )
        }
    }
    
    public func stopAll() {
        operations.forEach { operation in
            operation.downloadProgress?.cancel()
        }
    }
}

// MARK: - FileProvider Delegate
extension DownloadService: FileProviderDelegate {
    
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
        switch operation {
        case .copy(let source, _):
            if let index = operations.firstIndex(where: { $0.object.file?.path == source }) {
                operations[index].object.status = .complate
                onComplate?(operations[index].object, nil)
//                print("✅ Download complate - \(operations[index].object.file?.name ?? "")")
            }
            
            if operations.filter({ $0.object.status == .downloading }).count < 1 {
                onAllComplation?()
            }
        default:
            break
        }
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        switch operation {
        case .copy(let source, _):
            if let index = operations.firstIndex(where: { $0.object.file?.path == source }) {
                operations[index].object.status = .error
                onComplate?(operations[index].object, error)
//                print("❗️ Download complate - \(operations[index].object.file?.name ?? "")")
            }
            
            if operations.filter({ $0.object.status == .downloading }).count < 1 {
                onAllComplation?()
            }
        default:
            break
        }
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
        switch operation {
        case .copy(let source, _):
            if let index = operations.firstIndex(where: { $0.object.file?.path == source }) {
                operations[index].object.status = .downloading
                onProgress?(operations[index].object, progress)
//                print("Downloading - \(operations[index].object.file?.name ?? "") Progress: \(progress * 100)")
            }
        default:
            break
        }
    }
    
}
