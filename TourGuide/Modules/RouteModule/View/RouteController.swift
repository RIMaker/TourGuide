//
//  RouteController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 10.01.2023.
//

import UIKit
import MapKit

protocol RouteController: AnyObject {
    
}

class RouteControllerImpl: UIViewController, RouteController {
    
    var presenter: RoutePresenter?
    
    var closeButton: UIImageView = {
        let btn = UIImageView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        btn.image = UIImage(systemName: SystemSymbol.close.rawValue)
        btn.tintColor = UIColor(named: "CloseButtonColor")
        return btn
    }()
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @objc
    func close(_ sender: UIButton) {
        dismiss(animated: true)
    }

}
