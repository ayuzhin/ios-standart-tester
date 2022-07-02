//
//  BaseViewController.swift
//  FormatTester
//
//  Created by Alexander Yuzhin on 30.06.2022.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - Properties
        
    lazy var navigator = Navigator(navigationController: navigationController)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
