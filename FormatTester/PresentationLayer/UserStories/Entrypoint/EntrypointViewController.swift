//
//  EntrypointViewController.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 30.06.2022.
//

import UIKit

class EntrypointViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigator.navigate(to: .menu)
    }
}
