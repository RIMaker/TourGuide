//
//  Router.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 06.01.2023.
//

import UIKit

protocol RouterBase {
    var navController: UINavigationController? { get set }
    var viewFactory: ViewFactory? { get set }
}

protocol Router: RouterBase {
    func initialViewController()
    func showDetail(place: Feature?)
    func popToRoot()
}

class RouterPlacesListImpl: Router {
    
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
    
    func showDetail(place: Feature?) {
        if let navController = navController {
            guard let detailPlaceVC = viewFactory?.makeDetailPlaceScreen(place: place, router: self) else { return }
            navController.pushViewController(detailPlaceVC, animated: true)
        }
    }
    
    func popToRoot() {
        if let navController = navController {
            navController.popToRootViewController(animated: true)
        }
    }
    
}


class RouterMapImpl: Router {
    
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
    
    func showDetail(place: Feature?) {
//        if let navController = navController {
//            guard let detailPlaceVC = viewFactory?.makeDetailPlaceScreen(place: place, router: self) else { return }
//            navController.pushViewController(detailPlaceVC, animated: true)
//        }
    }
    
    func popToRoot() {
        if let navController = navController {
            navController.popToRootViewController(animated: true)
        }
    }
    
}
