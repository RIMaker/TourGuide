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
        return map
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
        view.bringSubviewToFront(closeButton)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close(_:)))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tapGestureRecognizer)
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
}

extension RouteControllerImpl: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        presenter?.checkLocationAuthorization()
    }
}
