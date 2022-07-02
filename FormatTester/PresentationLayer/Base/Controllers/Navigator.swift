//
//  Navigator.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 30.06.2022.
//

import UIKit

enum Destination {
    case menu, settings
}

class Navigator {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    

    // MARK: - Initialize
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    
    // MARK: - Public
    
    func navigate(to destination: Destination) {
        let viewController = makeViewController(for: destination)
        
        switch destination {
        
        case .menu:
            if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
                window.rootViewController = UINavigationController(rootViewController: viewController)
            }
            
        default:
            navigationController?.pushViewController(viewController, animated: true)
            break
        }
    }
    
    
    // MARK: - Private
    
    fileprivate func makeViewController(for destination: Destination) -> UIViewController {
        switch destination {
        
        case .menu:
            return MenuViewController()
        case .settings:
            return SettingsViewController()
        }
    }

}
