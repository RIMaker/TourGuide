//
//  MainViewController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.10.2022.
//

import UIKit

protocol MainViewController {
    
}

class MainViewControllerImpl: UITabBarController, MainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .label
    }
    
}
