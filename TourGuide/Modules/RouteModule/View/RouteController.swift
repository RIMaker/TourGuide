//
//  RouteController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 10.01.2023.
//

import UIKit
import MapKit

protocol RouteController: AnyObject {
    var locationManager: CLLocationManager { get }
    func setupViews()
    func showAnnotation(annotation: MKPointAnnotation)
    func showUserLocation()
    func addDirectionInMap(route: MKRoute)
    func showAlert(title: String, message: String)
}

class RouteControllerImpl: UIViewController, RouteController {
    
    var presenter: RoutePresenter?
    
    var locationManager = CLLocationManager()
    
    private let annotationID = "AnnotationID"
    
    private lazy var closeButton: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.close.rawValue)
        btn.tintColor = UIColor(named: "CloseButtonColor")
        return btn
    }()
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private lazy var centerInUserLocationButton: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.layer.cornerRadius = 35
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.paperplaneCircle.rawValue)
        btn.backgroundColor = UIColor(named: "PaperplaneColor")
        return btn
    }()
    
    private lazy var makeRouteButton: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.layer.cornerRadius = 50
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.makeRoute.rawValue)
        btn.backgroundColor = UIColor(named: "PaperplaneColor")
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.viewShown()
    }
    
    func setupViews() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
        
        view.addSubview(mapView)
        view.addSubview(closeButton)
        view.addSubview(centerInUserLocationButton)
        view.addSubview(makeRouteButton)
        view.sendSubviewToBack(mapView)
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let tapGestureRecognizerOfCloseButton = UITapGestureRecognizer(target: self, action: #selector(close(_:)))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tapGestureRecognizerOfCloseButton)
        
        centerInUserLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        centerInUserLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        centerInUserLocationButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        centerInUserLocationButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        let tapGestureRecognizerOfUserLocButton = UITapGestureRecognizer(target: self, action: #selector(setCenterToUserLocation(_:)))
        centerInUserLocationButton.isUserInteractionEnabled = true
        centerInUserLocationButton.addGestureRecognizer(tapGestureRecognizerOfUserLocButton)
        
        makeRouteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        makeRouteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        makeRouteButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        makeRouteButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let tapGestureRecognizerOfMakeRouteButton = UITapGestureRecognizer(target: self, action: #selector(makeRoute(_:)))
        makeRouteButton.isUserInteractionEnabled = true
        makeRouteButton.addGestureRecognizer(tapGestureRecognizerOfMakeRouteButton)
    }
    
    func showAnnotation(annotation: MKPointAnnotation) {
        DispatchQueue.main.async { [weak self] in
            self?.mapView.showAnnotations([annotation], animated: true)
            self?.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func showUserLocation() {
        mapView.showsUserLocation = true
    }
    
    func addDirectionInMap(route: MKRoute) {
        mapView.addOverlay(route.polyline)
        mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        
        let distance = String(format: "%.1f", route.distance / 1000)
        let timeInterval = route.expectedTravelTime
        print("Расстояние \(distance)")
        print("time \(timeInterval)")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @objc
    private func close(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc
    private func setCenterToUserLocation(_ sender: UIButton) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: 8000,
                longitudinalMeters: 8000
            )
            DispatchQueue.main.async { [weak self] in
                self?.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    @objc
    private func makeRoute(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.makeRouteButton.isHidden = true
        }
        presenter?.getDirections()
    }

}


extension RouteControllerImpl: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotationView?.canShowCallout = true
        }
        if let urlString = presenter?.place?.preview?.source, let url = URL(string: urlString) {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.load(url: url)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension RouteControllerImpl: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        presenter?.checkLocationAuthorization()
    }
}
