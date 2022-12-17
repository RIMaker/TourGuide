//
//  ViewFactory.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.10.2022.
//

import UIKit

enum ScreenIdentifier {
    case mainScreen
    case launchScreen
    case mapScreen
}


protocol ViewFactory {
    func makeView(for screenIdentifier: ScreenIdentifier) -> UIViewController?
}

class ViewFactoryImpl: ViewFactory {
    
    func makeView(for screenIdentifier: ScreenIdentifier) -> UIViewController? {
        switch screenIdentifier {
        case .mainScreen: return makeMainScreen()
        case .launchScreen: return makeLaunchScreen()
        case .mapScreen: return makeMapScreen()
        }
    }
    
}

// MARK: - Supporting functions
extension ViewFactoryImpl {
    
    func makeMainScreen() -> UIViewController {
        let mainVC = MainViewController()
        mainVC.viewControllers = [
            makeMapScreen(title: "Карта", image: .map)
        ]
        return mainVC
    }
    
    func makeLaunchScreen() -> UIViewController? {
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: .main)
        let launchScreen = storyboard.instantiateInitialViewController()
        return launchScreen
    }
    
    func makeMapScreen(title: String? = nil, image: SystemSymbol? = nil) -> UIViewController {
        let mapVC = MapViewControllerImpl()
        mapVC.tabBarItem.title = title
        if let image = image {
            mapVC.tabBarItem.image = UIImage(systemName: image.rawValue)
        }
        return mapVC
    }
    
}

