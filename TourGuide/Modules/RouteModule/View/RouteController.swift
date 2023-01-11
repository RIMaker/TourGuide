//
//  RouteController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 10.01.2023.
//

import UIKit
import MapKit

protocol RouteController: AnyObject {
    func setupViews()
}

class RouteControllerImpl: UIViewController, RouteController {
    
    var presenter: RoutePresenter?
    
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
    
    private lazy var goOnFoot: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.layer.cornerRadius = 50
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.makeRouteByFoot.rawValue)
        return btn
    }()
    
    private lazy var goByCar: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.layer.cornerRadius = 50
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.makeRouteByCar.rawValue)
        return btn
    }()
    
    private lazy var makeRouteStackView: UIStackView = {
        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.spacing = 15
        hStack.layer.cornerRadius = 50
        hStack.clipsToBounds = true
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        hStack.axis = .horizontal
        hStack.backgroundColor = UIColor(named: "PaperplaneColor")
        return hStack
    }()
    
    private lazy var infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 30)
        lbl.textAlignment = .center
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        presenter?.viewShown(mapView: mapView)
    }
    
    func setupViews() {
        mapView.delegate = self
        presenter?.mapManager?.checkLocationAuthorization {
            self.presenter?.mapManager?.locationManager.delegate = self
        }
        
        view.addSubview(mapView)
        view.addSubview(closeButton)
        view.addSubview(centerInUserLocationButton)
        view.addSubview(makeRouteStackView)
        view.addSubview(infoLabel)
        view.sendSubviewToBack(mapView)
        makeRouteStackView.addArrangedSubview(goByCar)
        makeRouteStackView.addArrangedSubview(goOnFoot)
        
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
        
        infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        makeRouteStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        makeRouteStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        goByCar.widthAnchor.constraint(equalToConstant: 100).isActive = true
        goByCar.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let tapGestureRecognizerOfGoByCarButton = UITapGestureRecognizer(
            target: self,
            action: #selector(makeRouteByCar(_:)))
        goByCar.isUserInteractionEnabled = true
        goByCar.addGestureRecognizer(tapGestureRecognizerOfGoByCarButton)
        
        goOnFoot.widthAnchor.constraint(equalToConstant: 100).isActive = true
        goOnFoot.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let tapGestureRecognizerOfGoOnFootButton = UITapGestureRecognizer(
            target: self,
            action: #selector(makeRouteOnFoot(_:)))
        goOnFoot.isUserInteractionEnabled = true
        goOnFoot.addGestureRecognizer(tapGestureRecognizerOfGoOnFootButton)
    }
    
    @objc
    private func close(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc
    private func setCenterToUserLocation(_ sender: UIButton) {
        presenter?.mapManager?.showUserLocation()
    }
    
    @objc
    private func makeRouteByCar(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.makeRouteStackView.isHidden = true
        }
        presenter?.mapManager?.getDirections(place: presenter?.place, by: .automobile) { [weak self] info in
            DispatchQueue.main.async {
                self?.infoLabel.text = info
                self?.infoLabel.isHidden = false
            }
        }
    }
    
    @objc
    private func makeRouteOnFoot(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.makeRouteStackView.isHidden = true
        }
        presenter?.mapManager?.getDirections(place: presenter?.place, by: .walking) { [weak self] info in
            DispatchQueue.main.async {
                self?.infoLabel.text = info
                self?.infoLabel.isHidden = false
            }
        }
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
        presenter?.mapManager?.checkLocationAuthorization(completion: nil)
    }
}
