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
    init(networkManager: NetworkManager, cacheManager: CacheManager, view: PlacesListController?, router: RouterPlacesListScreen?)
    func viewShown()
    func tapOnThePlace(place: Feature?)
    func updateData()
    func startUpdatingLocation()
    func searchCompleted(placemark: CLPlacemark)
    func distanceToUser(fromPlace place: MKMapItem) -> Int
    func stopUpdatingLocation()
}

class PlacesListPresenterImpl: PlacesListPresenter {
    
    var places: Places?
    
    private var userLocation: CLPlacemark?
    
    private var router: RouterPlacesListScreen?
    
    private let networkManager: NetworkManager
    
    private weak var view: PlacesListController?
    
    private let cacheManager: CacheManager
    
    required init(networkManager: NetworkManager, cacheManager: CacheManager, view: PlacesListController?, router: RouterPlacesListScreen?) {
        self.networkManager = networkManager
        self.cacheManager = cacheManager
        self.view = view
        self.router = router
    }
    
    private func fetchData() {
        DispatchQueue.main.async { [weak self] in
            self?.view?.actIndStartAnimating()
        }
        if shouldUpdateData() {
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
    
    private func shouldUpdateData() -> Bool {
        let lastUpdatingDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastUpdatingDateKey.rawValue) as? Date
        let cachedData = cacheManager.cachedData()
        let nowDate = Date()
        if let lastUpdatingDate = lastUpdatingDate, let _ = cachedData {
            if nowDate.timeIntervalSince(lastUpdatingDate) >= 3600 {
                return true
            }
            return false
        }
        return true
    }
    
    private func getLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            view?.locationManager.requestLocation()
        }
    }
    
    private func requestLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            view?.locationManager.requestWhenInUseAuthorization()
        }
        startUpdatingLocation()
    }
    
    func viewShown() {
        view?.setupViews()
        fetchData()
        requestLocation()
    }
    
    func tapOnThePlace(place: Feature?) {
        router?.showDetail(place: place, userLocation: userLocation)
    }
    
    func updateData() {
        fetchData()
        requestLocation()
    }
    
    func distanceToUser(fromPlace place: MKMapItem) -> Int {
        if let userLocation = userLocation?.location, let placeLoc = place.placemark.location {
            return Int(userLocation.distance(from: placeLoc))
        } else {
            return 0
        }
    }
    
    func searchCompleted(placemark: CLPlacemark) {
        userLocation = placemark
        stopUpdatingLocation()
        DispatchQueue.main.async { [weak self] in
            self?.view?.reloadData()
        }
    }
    
    func startUpdatingLocation() {
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.view?.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func stopUpdatingLocation() {
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.view?.locationManager.stopUpdatingLocation()
            }
        }
    }
    
}
