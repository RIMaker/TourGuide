//
//  MapManager.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 11.01.2023.
//

import UIKit
import MapKit

protocol MapManagerRouteModule {
    var locationManager: CLLocationManager { get }
    func setupPlacemark(place: PlaceProperties?, mapView: MKMapView)
    func checkLocationAuthorization(completion: (() -> ())?)
    func showUserLocation()
    func getDirections(place: PlaceProperties?, by transportType: MKDirectionsTransportType, completion: @escaping (String?)->())
}

protocol MapManagerPlacesModule {
    var locationManager: CLLocationManager { get }
    func getLocation()
    func requestLocation()
    func distanceToUser(userLocation: CLPlacemark?, fromPlace place: MKMapItem, completion: @escaping (String?)->())
}

protocol MapManagerMapModule {
    var locationManager: CLLocationManager { get }
}

class MapManager {
    
    var locationManager = CLLocationManager()
    
    private var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    private let regionInMeter = 1000.00
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    private var mapView: MKMapView?
    
    private func showAlert(title: String, message: String) {
        print(title)
        print(message)
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let action = UIAlertAction(title: "OK", style: .default)
//        alert.addAction(action)
//
//        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
//        alertWindow.rootViewController = UIViewController()
//        alertWindow.windowLevel = UIWindow.Level.alert + 1
//        alertWindow.makeKeyAndVisible()
//        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
    private func startTrackingUserLocation() {
        guard
            let previousLocation = previousLocation
        else { return }
        let center = getCenterLocation()
        guard let distance = center?.distance(from: previousLocation), distance > 50 else { return }
        self.previousLocation = center
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showUserLocation()
        }
    }
    
    private func getCenterLocation() -> CLLocation? {
        guard
            let latitude = mapView?.centerCoordinate.latitude,
            let longitude = mapView?.centerCoordinate.longitude
        else { return nil }
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func createDirectionsRequest(place: PlaceProperties?, from coordinate: CLLocationCoordinate2D, by transportType: MKDirectionsTransportType) -> MKDirections.Request? {
        guard
            let lat = place?.point?.lat,
            let lon = place?.point?.lon
        else { return nil }
        
        let destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = transportType
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func resetMapView(withDirections directions: MKDirections) {
        guard let mapView = mapView else { return }
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
}


// MARK: RouteManager
extension MapManager: MapManagerRouteModule {
    func setupPlacemark(place: PlaceProperties?, mapView: MKMapView) {
        self.mapView = mapView
        guard
            let lat = place?.point?.lat,
            let lon = place?.point?.lon
        else { return }
        
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.coordinate = coordinate
        annotation.title = place?.name
        annotation.subtitle = place?.getAddress(type: .short)
        DispatchQueue.main.async { [weak self] in
            self?.mapView?.showAnnotations([annotation], animated: true)
            self?.mapView?.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationAuthorization(completion: (() -> ())?) {
        completion?()
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            mapView?.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.showAlert(
                    title: "Ваше местоположение недоступно",
                    message: "Перейдите в Настройки -> TourGuide -> Геопозиция")
            }
        default: break
        }
        
    }
    
    func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: regionInMeter,
                longitudinalMeters: regionInMeter
            )
            DispatchQueue.main.async { [weak self] in
                self?.mapView?.setRegion(region, animated: true)
            }
        }
    }
    
    func getDirections(place: PlaceProperties?, by transportType: MKDirectionsTransportType, completion: @escaping (String?)->()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Ошибка", message: "Текущее местопложение не обнаружено")
            completion(nil)
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(place: place, from: location, by: transportType) else {
            showAlert(title: "Ошибка", message: "Место назначения не найдено")
            completion(nil)
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withDirections: directions)
        
        directions.calculate { [weak self] (response, error) in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            guard let response = response else {
                self?.showAlert(title: "Ошибка", message: "Маршрут не доступен")
                completion(nil)
                return
            }
            let routes = response.routes.sorted { $0.expectedTravelTime < $1.expectedTravelTime }
            if let route = routes.first {
                self?.mapView?.addOverlay(route.polyline)
                self?.mapView?.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.2f", route.distance / 1000)
                let timeIntervalH = String(format: "%d", Int(route.expectedTravelTime) / 3600)
                let timeIntervalM = String(format: "%d", Int(route.expectedTravelTime) % 3600 / 60)
                if timeIntervalH != "0" {
                    completion("\(timeIntervalH)ч. \(timeIntervalM)мин.   \(distance)км.")
                } else {
                    completion("\(timeIntervalM)мин.   \(distance)км.")
                }
            } else {
                completion(nil)
            }
            
        }
    }
    
}


// MARK: PlacesManager
extension MapManager: MapManagerPlacesModule {
    func getLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func requestLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func distanceToUser(userLocation: CLPlacemark?, fromPlace place: MKMapItem, completion: @escaping (String?)->()) {
        let queue = DispatchQueue(label: "distanceToUser", qos: .userInitiated)
        queue.async {
            if let userLocation = userLocation?.location, let placeLoc = place.placemark.location {
                completion(String(format: "%.2f", userLocation.distance(from: placeLoc) / 1000))
            } else {
                completion(nil)
            }
        }
    }
}
