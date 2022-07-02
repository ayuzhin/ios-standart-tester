//
//  StandartTesterServices.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 02.07.2022.
//

import Foundation

final class StandartTesterServices {
    
    // MARK: - Lifecycle Methods
    
    func doMagic(with files: [URL], complation: () -> Void) {
        print("List of files: - \(files)")
        complation()
    }
}
