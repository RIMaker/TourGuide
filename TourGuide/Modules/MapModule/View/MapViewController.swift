//
//  MainViewController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.10.2022.
//

import UIKit
import MapKit

protocol MapViewController: AnyObject {
    func setupViews()
}

class MapViewControllerImpl: UIViewController, MapViewController {
    
    var presenter: MapPresenter?
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    private var isShowingDirection = false
    
    private lazy var centerInUserLocationButton: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.layer.cornerRadius = 30
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.userLocation.rawValue)
        btn.backgroundColor = .init(white: 1, alpha: 0.8)
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var goOnFoot: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.layer.cornerRadius = 50
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.makeRouteByFoot.rawValue)
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var goByCar: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.layer.cornerRadius = 50
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.makeRouteByCar.rawValue)
        btn.tintColor = .black
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
        hStack.backgroundColor = .init(white: 1, alpha: 0.8)
        return hStack
    }()
    
    private lazy var pinView: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        btn.image = UIImage(named: "Pin")
        return btn
    }()
    
    private lazy var stopRoutingView: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.backgroundColor = .init(white: 1, alpha: 0.8)
        btn.layer.cornerRadius = 40
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.stopRouting.rawValue)
        btn.tintColor = .black
        btn.isHidden = true
        return btn
    }()
    
    private lazy var infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 30)
        lbl.textAlignment = .center
        return lbl
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewShown(mapView: mapView)
    }
    
    func setupViews() {
        mapView.delegate = self
        presenter?.mapManager?.checkLocationAuthorization {
            self.presenter?.mapManager?.locationManager.delegate = self
        }
        
        view.addSubview(mapView)
        view.addSubview(centerInUserLocationButton)
        view.addSubview(makeRouteStackView)
        view.addSubview(stopRoutingView)
        view.addSubview(infoLabel)
        view.addSubview(pinView)
        view.sendSubviewToBack(mapView)
        makeRouteStackView.addArrangedSubview(goByCar)
        makeRouteStackView.addArrangedSubview(goOnFoot)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        centerInUserLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        centerInUserLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        centerInUserLocationButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        centerInUserLocationButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let tapGestureRecognizerOfUserLocButton = UITapGestureRecognizer(target: self, action: #selector(setCenterToUserLocation(_:)))
        centerInUserLocationButton.isUserInteractionEnabled = true
        centerInUserLocationButton.addGestureRecognizer(tapGestureRecognizerOfUserLocButton)
        
        infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        makeRouteStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        makeRouteStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stopRoutingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        stopRoutingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stopRoutingView.widthAnchor.constraint(equalToConstant: 170).isActive = true
        stopRoutingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let tapGestureRecognizerOfStopRoutingView = UITapGestureRecognizer(
            target: self,
            action: #selector(stopRouting(_:)))
        stopRoutingView.isUserInteractionEnabled = true
        stopRoutingView.addGestureRecognizer(tapGestureRecognizerOfStopRoutingView)
        
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
        
        pinView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        pinView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        pinView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -25).isActive = true
        pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc
    private func setCenterToUserLocation(_ sender: UIButton) {
        presenter?.mapManager?.showUserLocation()
    }
    
    @objc
    private func makeRouteByCar(_ sender: UIButton) {
        isShowingDirection = true
        let center = presenter?.mapManager?.getCenterLocation()
        presenter?.mapManager?.setupPlacemark(
            lat: center?.coordinate.latitude,
            lon: center?.coordinate.longitude,
            title: nil,
            subtitle: nil)
        presenter?.mapManager?.getDirections(
            lat: center?.coordinate.latitude,
            lon: center?.coordinate.longitude,
            by: .automobile) { [weak self] info in
            DispatchQueue.main.async {
                self?.infoLabel.text = info
                self?.makeRouteStackView.isHidden = true
                self?.pinView.isHidden = true
                self?.stopRoutingView.isHidden = false
            }
        }
    }
    
    @objc
    private func makeRouteOnFoot(_ sender: UIButton) {
        isShowingDirection = true
        let center = presenter?.mapManager?.getCenterLocation()
        presenter?.mapManager?.setupPlacemark(
            lat: center?.coordinate.latitude,
            lon: center?.coordinate.longitude,
            title: nil,
            subtitle: nil)
        presenter?.mapManager?.getDirections(
            lat: center?.coordinate.latitude,
            lon: center?.coordinate.longitude,
            by: .walking) { [weak self] info in
            DispatchQueue.main.async {
                self?.infoLabel.text = info
                self?.makeRouteStackView.isHidden = true
                self?.pinView.isHidden = true
                self?.stopRoutingView.isHidden = false
            }
        }
    }
    
    @objc
    private func stopRouting(_ sender: UIButton) {
        presenter?.mapManager?.resetMapView()
        presenter?.mapManager?.removeAnnotation()
        DispatchQueue.main.async { [weak self] in
            self?.infoLabel.text = ""
            self?.makeRouteStackView.isHidden = false
            self?.pinView.isHidden = false
            self?.isShowingDirection = false
            self?.stopRoutingView.isHidden = true
        }
    }

}

extension MapViewControllerImpl: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = presenter?.mapManager?.getCenterLocation()
        if let center = center, !isShowingDirection {
            let geocoder = CLGeocoder()
            
            geocoder.cancelGeocode()
            
            geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
                
                if let error = error {
                    print(error)
                    return
                }
                
                guard let placemarks = placemarks else { return }
                
                let placemark = placemarks.first
                let streetName = placemark?.thoroughfare
                let buildNumber = placemark?.subThoroughfare
                
                DispatchQueue.main.async { [weak self] in
                    
                    if streetName != nil && buildNumber != nil {
                        self?.infoLabel.text = "\(streetName!), \(buildNumber!)"
                    } else if streetName != nil {
                        self?.infoLabel.text = "\(streetName!)"
                    } else {
                        self?.infoLabel.text = ""
                    }
                }
            }
        }
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.presenter?.mapManager?.showUserLocation()
        }
    }
}

extension MapViewControllerImpl: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        presenter?.mapManager?.checkLocationAuthorization(completion: nil)
    }
}
