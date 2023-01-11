//
//  PlacesListVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 27.12.2022.
//

import Foundation
import MapKit

protocol PlacesListPresenter {
    var places: Places? { get }
    var mapManager: MapManagerPlacesModule? { get }
    var userLocation: CLPlacemark? { get }
    init(networkManager: NetworkManager, cacheManager: CacheManager, mapManager: MapManagerPlacesModule, view: PlacesListController?, router: RouterPlacesListScreen?)
    func viewShown()
    func tapOnThePlace(place: Feature?)
    func updateData()
    func searchCompleted(placemark: CLPlacemark)
}

class PlacesListPresenterImpl: PlacesListPresenter {
    
    var places: Places?
    var mapManager: MapManagerPlacesModule?
    var userLocation: CLPlacemark?
    
    private var router: RouterPlacesListScreen?
    
    private let networkManager: NetworkManager
    
    private weak var view: PlacesListController?
    
    private let cacheManager: CacheManager
    
    required init(networkManager: NetworkManager, cacheManager: CacheManager, mapManager: MapManagerPlacesModule, view: PlacesListController?, router: RouterPlacesListScreen?) {
        self.networkManager = networkManager
        self.cacheManager = cacheManager
        self.view = view
        self.router = router
        self.mapManager = mapManager
    }
    
    private func fetchData() {
        DispatchQueue.main.async { [weak self] in
            self?.view?.actIndStartAnimating()
        }
        if cacheManager.shouldUpdateData() {
            let url = APIProvider.shared.placesURL()
            networkManager.fetchData(Places.self, forURL: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let places):
                    DispatchQueue.main.async {
                        self.places = places
                        self.view?.actIndStopAnimating()
                        self.view?.reloadData()
                    }
                    DispatchQueue.global().async {
                        self.cacheManager.cache(data: places)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            self.places = cacheManager.cachedData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.view?.actIndStopAnimating()
                self?.view?.reloadData()
            }
        }
    }
    
    func viewShown() {
        view?.setupViews()
        fetchData()
        mapManager?.requestLocation()
    }
    
    func tapOnThePlace(place: Feature?) {
        router?.showDetail(place: place, userLocation: userLocation)
    }
    
    func updateData() {
        fetchData()
        mapManager?.requestLocation()
    }
    
    func searchCompleted(placemark: CLPlacemark) {
        userLocation = placemark
        mapManager?.locationManager.stopUpdatingLocation()
        DispatchQueue.main.async { [weak self] in
            self?.view?.reloadData()
        }
    }
    
}
