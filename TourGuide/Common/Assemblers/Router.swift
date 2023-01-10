//
//  Router.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 06.01.2023.
//

import UIKit
import MapKit

protocol RouterBase {
    var navController: UINavigationController? { get set }
    var viewFactory: ViewFactory? { get set }
    func popToRoot()
}

// MARK: RouterPlacesList
protocol RouterPlacesListScreen: RouterBase {
    func initialViewController()
    func showDetail(place: Feature?, userLocation: CLPlacemark?)
}

protocol RouterPlaceDetailsScreen: RouterBase {
    func makeRoute(place: Feature?)
}

protocol RouterRouteScreen: RouterBase {
    
}

class RouterPlacesListImpl: RouterPlacesListScreen, RouterPlaceDetailsScreen, RouterRouteScreen {
    
    var navController: UINavigationController?
    
    var viewFactory: ViewFactory?
    
    init(navController: UINavigationController, viewFactory: ViewFactory) {
        self.navController = navController
        self.viewFactory = viewFactory
    }
    
    func initialViewController() {
        if let navController = navController {
            guard let placesListVC = viewFactory?.makePlacesListScreen(title: "Места", image: .places, router: self) else { return }
            navController.viewControllers = [placesListVC]
        }
    }
    
    func popToRoot() {
        if let navController = navController {
            navController.popToRootViewController(animated: true)
        }
    }
    
    func showDetail(place: Feature?, userLocation: CLPlacemark?) {
        if let navController = navController {
            guard let placeDetailsVC = viewFactory?.makePlaceDetailsScreen(place: place, userLocation: userLocation, router: self) else { return }
            navController.pushViewController(placeDetailsVC, animated: true)
        }
    }
    
    func makeRoute(place: Feature?) {
        if let navController = navController {
            guard let placeDetailsVC = viewFactory?.makeRouteScreen(place: place, router: self) else { return }
            navController.present(placeDetailsVC, animated: true)
        }
    }
    
}


// MARK: RouterMap
protocol RouterMap: RouterBase {
    func initialViewController()
}

class RouterMapImpl: RouterMap {
    
    var navController: UINavigationController?
    
    var viewFactory: ViewFactory?
    
    init(navController: UINavigationController, viewFactory: ViewFactory) {
        self.navController = navController
        self.viewFactory = viewFactory
    }
    
    func initialViewController() {
        if let navController = navController {
            guard let mapVC = viewFactory?.makeMapScreen(title: "Карта", image: .map, router: self) else { return }
            navController.viewControllers = [mapVC]
        }
    }
    
    func popToRoot() {
        if let navController = navController {
            navController.popToRootViewController(animated: true)
        }
    }
    
}
