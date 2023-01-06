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
    case placesList
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
        case .placesList: return makePlacesListScreen()
        }
    }
    
}

// MARK: - Supporting functions
extension ViewFactoryImpl {
    
    func makeMainScreen() -> UIViewController {
        let mainVC = MainViewControllerImpl()
        mainVC.viewControllers = [
            makeMapScreen(title: "Карта", image: .map),
            makePlacesListScreen(title: "Места", image: .places)
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
        let mapVCPresenter: MapVCPresenter = MapVCPresenterImpl(view: mapVC)
        mapVC.presenter = mapVCPresenter
        mapVC.tabBarItem.title = title
        if let image = image {
            mapVC.tabBarItem.image = UIImage(systemName: image.rawValue)
        }
        return mapVC
    }
    
    func makePlacesListScreen(title: String? = nil, image: SystemSymbol? = nil) -> UIViewController {
        let placesVC = PlacesListControllerImpl()
        let placesVCPresenter: PlacesListVCPresenter = PlacesListVCPresenterImpl(
            networkManager: NetworkManagerImpl(),
            cacheManager: CacheManagerImpl(),
            view: placesVC)
        placesVC.presenter = placesVCPresenter
        placesVC.tabBarItem.title = title
        if let image = image {
            placesVC.tabBarItem.image = UIImage(systemName: image.rawValue)
        }
        let navController = UINavigationController(rootViewController: placesVC)
        return navController
    }
    
}

