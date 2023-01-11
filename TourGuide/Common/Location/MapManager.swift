//
//  MapManager.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 11.01.2023.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    private let regionInMeter = 1000.00
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    private var mapView: MKMapView?
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
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
    
    func checkLocationServices(closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization()
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.showAlert(
                    title: "Ваше местоположение недоступно",
                    message: "Перейдите в Настройки -> TourGuide -> Геопозиция")
            }
        }
    }
    
    func checkLocationAuthorization() {
        DispatchQueue.main.async { [weak self] in
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                self?.locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                self?.mapView?.showsUserLocation = true
            case .denied:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.showAlert(
                        title: "Ваше местоположение недоступно",
                        message: "Перейдите в Настройки -> TourGuide -> Геопозиция")
                }
            default: break
            }
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
    
    func getDirections(place: PlaceProperties?) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Ошибка", message: "Текущее местопложение не обнаружено")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(place: place, from: location) else {
            showAlert(title: "Ошибка", message: "Место назначения не найдено")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withDirections: directions)
        
        directions.calculate { [weak self] (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self?.showAlert(title: "Ошибка", message: "Маршрут не доступен")
                return
            }
            let routes = response.routes.sorted { $0.expectedTravelTime < $1.expectedTravelTime }
            if let route = routes.first {
                self?.mapView?.addOverlay(route.polyline)
                self?.mapView?.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                print("Расстояние \(distance)")
                print("time \(timeInterval)")
            }
            
        }
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
    
    private func createDirectionsRequest(place: PlaceProperties?, from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
        request.transportType = .automobile
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
