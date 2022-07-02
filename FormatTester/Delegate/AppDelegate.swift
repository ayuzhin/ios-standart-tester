//
//  AppDelegate.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 30.06.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {   
        Const.setupDefaults()
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = EntrypointViewController()
        
        return true
    }


}

