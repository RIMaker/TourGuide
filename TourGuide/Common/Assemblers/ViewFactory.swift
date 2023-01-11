//
//  ViewFactory.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.10.2022.
//

import UIKit
import MapKit

protocol ViewFactory {
    func makeMainScreen() -> UIViewController
    func makeLaunchScreen() -> UIViewController?
    func makeMapScreen(title: String?, image: SystemSymbol?, router: RouterMap) -> UIViewController
    func makePlacesListScreen(title: String?, image: SystemSymbol?, router: RouterPlacesListScreen) -> UIViewController
    func makePlaceDetailsScreen(place: Feature?,  userLocation: CLPlacemark?, router: RouterPlaceDetailsScreen) -> UIViewController
    func makeRouteScreen(place: PlaceProperties?) -> UIViewController
}

class ViewFactoryImpl: ViewFactory {
    
    func makeMainScreen() -> UIViewController {
        let mainVC = UITabBarController()
        mainVC.tabBar.tintColor = .label
        mainVC.definesPresentationContext = true
        let placesNavController = UINavigationController()
        let mapNavController = UINavigationController()
        let placesListRouter: RouterPlacesListScreen = RouterPlacesListImpl(navController: placesNavController, viewFactory: self)
        let mapRouter: RouterMap = RouterMapImpl(navController: mapNavController, viewFactory: self)
        placesListRouter.initialViewController()
        mapRouter.initialViewController()
        mainVC.viewControllers = [
            mapNavController,
            placesNavController
        ]
        return mainVC
    }
    
    func makeLaunchScreen() -> UIViewController? {
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: .main)
        let launchScreen = storyboard.instantiateInitialViewController()
        return launchScreen
    }
    
    func makeMapScreen(title: String? = nil, image: SystemSymbol? = nil, router: RouterMap) -> UIViewController {
        let mapVC = MapViewControllerImpl()
        let mapVCPresenter: MapPresenter = MapPresenterImpl(view: mapVC, router: router)
        mapVC.presenter = mapVCPresenter
        mapVC.tabBarItem.title = title
        if let image = image {
            mapVC.tabBarItem.image = UIImage(systemName: image.rawValue)
        }
        return mapVC
    }
    
    func makePlacesListScreen(title: String? = nil, image: SystemSymbol? = nil, router: RouterPlacesListScreen) -> UIViewController {
        let placesVC = PlacesListControllerImpl()
        let placesVCPresenter: PlacesListPresenter = PlacesListPresenterImpl(
            networkManager: NetworkManagerImpl(),
            cacheManager: CacheManagerImpl(),
            mapManager: MapManager(),
            view: placesVC,
            router: router)
        placesVC.presenter = placesVCPresenter
        placesVC.tabBarItem.title = title
        if let image = image {
            placesVC.tabBarItem.image = UIImage(systemName: image.rawValue)
        }
        return placesVC
    }
    
    func makePlaceDetailsScreen(place: Feature?, userLocation: CLPlacemark?, router: RouterPlaceDetailsScreen) -> UIViewController {
        let placesDetailsVC = PlaceDetailsControllerImpl()
        let placeDetailsVCPresenter: PlaceDetailsPresenter = PlaceDetailsPresenterImpl(
            place: place,
            userLocation: userLocation,
            networkManager: NetworkManagerImpl(),
            view: placesDetailsVC,
            router: router)
        placesDetailsVC.presenter = placeDetailsVCPresenter
        return placesDetailsVC
    }
    
    func makeRouteScreen(place: PlaceProperties?) -> UIViewController {
        let routeVC = RouteControllerImpl()
        let mapManager = MapManager()
        let routeVCPresenter: RoutePresenter = RoutePresenterImpl(
            place: place,
            mapManager: mapManager,
            view: routeVC)
        routeVC.presenter = routeVCPresenter
        return routeVC
    }
    
}

