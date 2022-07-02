//
//  Const.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 02.07.2022.
//

import Foundation

struct Const {
    
    enum SettingsKeys {
        static let serverAddress = "server-address"
        static let serverLogin = "server-login"
        static let serverPassword = "server-password"
    }
    
    static func setupDefaults() {
        UserDefaults.standard.register(
            defaults: [
                Const.SettingsKeys.serverAddress: "http://localhost:8787",
                Const.SettingsKeys.serverLogin: "test",
                Const.SettingsKeys.serverPassword: "test",
            ]
        )
    }
}
