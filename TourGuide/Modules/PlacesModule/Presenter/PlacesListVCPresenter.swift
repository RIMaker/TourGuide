//
//  PlacesListVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 27.12.2022.
//

import Foundation
import MapKit

protocol PlacesListVCPresenter {
    var router: Router? { get }
    var places: Places? { get }
    init(networkManager: NetworkManager, cacheManager: CacheManager, view: PlacesListController?, router: Router?)
    func viewShown()
    func tapOnThePlace(place: Feature)
    func updateData()
    func startUpdatingLocation()
    func searchCompleted(placemark: CLPlacemark)
    func distanceToUser(fromPlace place: MKMapItem) -> Int
    func stopUpdatingLocation()
}

class PlacesListVCPresenterImpl: PlacesListVCPresenter {
    
    var places: Places?
    
    var router: Router?
    
    private let networkManager: NetworkManager
    
    private weak var view: PlacesListController?
    
    private var userLocation: CLPlacemark?
    
    private let cacheManager: CacheManager
    
    required init(networkManager: NetworkManager, cacheManager: CacheManager, view: PlacesListController?, router: Router?) {
        self.networkManager = networkManager
        self.cacheManager = cacheManager
        self.view = view
        self.router = router
    }
    
    private func fetchData() {
        DispatchQueue.main.async {
            self.view?.actIndStartAnimating()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.view?.actIndStopAnimating()
                self.view?.reloadData()
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

    private func getPlaceProperties(withID id: String, completion: @escaping (PlaceProperties?)->()) {
        let url = APIProvider.shared.propertiesOfObjectURL(withId: id)
        networkManager.fetchData(PlaceProperties.self, forURL: url) { result in
            switch result {
            case .success(let prop):
                completion(prop)
            case .failure(let error):
                print(error)
            }
        }
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
    
    func tapOnThePlace(place: Feature) {
        router?.showDetail(place: place)
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
        DispatchQueue.main.async {
            self.view?.reloadData()
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
    
    func getAddressFromLatLon(lat: Double, lon: Double, completion: @escaping (String)->()) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if (error != nil)
            {
                completion("")
            }
            
            if let placemarks = placemarks, placemarks.count > 0 {
                let pm = placemarks[0]
                
                var addressString : String = ""
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                }
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ""
                }
                
                completion(addressString)
            } else {
                completion("")
            }
        })
        
    }
    
}
