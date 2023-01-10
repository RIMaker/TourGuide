//
//  PlacesListController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import UIKit
import MapKit

protocol PlacesListController: AnyObject {
    var locationManager: CLLocationManager { get }
    func setupViews()
    func actIndStopAnimating()
    func actIndStartAnimating()
    func reloadData()
}

class PlacesListControllerImpl: UIViewController, PlacesListController {
    
    var locationManager = CLLocationManager()
    
    var presenter: PlacesListVCPresenter?
    
    private var collectionView: UICollectionView?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let actInd = UIActivityIndicatorView()
        actInd.translatesAutoresizingMaskIntoConstraints = false
        actInd.isHidden = true
        actInd.style = .large
        actInd.hidesWhenStopped = true
        actInd.startAnimating()
        return actInd
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewShown()
    }
    
    func setupViews() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Места"
        let view = UIView()
        view.frame = self.view.frame
                
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 18, bottom: 20, right: 18)
        layout.itemSize = CGSize(width: view.frame.size.width - 20, height: 87)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20;
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView?.register(PlaceCell.self, forCellWithReuseIdentifier: PlaceCell.cellIdentifier)
        collectionView?.backgroundColor = .systemBackground
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(updateData(_:)), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        view.addSubview(collectionView!)
        view.addSubview(activityIndicator)
            
        self.view = view
        
        activityIndicator.centerXAnchor.constraint(
            equalTo: self.view.centerXAnchor
        ).isActive = true
        activityIndicator.centerYAnchor.constraint(
            equalTo: self.view.centerYAnchor,
            constant: -(navigationController?.navigationBar.frame.height ?? 0)
        ).isActive = true
    }
    
    @objc
    private func updateData(_ sender: Any) {
        presenter?.updateData()
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    func reloadData() {
        if let collectionView = collectionView {
            self.collectionView?.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }
    
    func actIndStopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    func actIndStartAnimating() {
        activityIndicator.startAnimating()
    }

}


// MARK: Delegate
extension PlacesListControllerImpl: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter?.places?.features.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCell.cellIdentifier, for: indexPath) as! PlaceCell
            
        let feature = presenter?.places?.features[indexPath.item]
        myCell.place = feature
        if let coordinates = feature?.geometry?.coordinates {
            let placeMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0]))
            myCell.distanceToUser = presenter?.distanceToUser(fromPlace: MKMapItem(placemark: placeMark))
        }
        return myCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.tapOnThePlace(place: presenter?.places?.features[indexPath.item])
    }
}


extension PlacesListControllerImpl: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geocoder = CLGeocoder()
        if let loc = locations.last {
            geocoder.reverseGeocodeLocation(loc) { [weak self] (placemarks, error) in
                if error != nil {
                    print("error")
                } else {
                    if let placemark = placemarks?.first {
                        print(placemark.debugDescription)
                        self?.presenter?.searchCompleted(placemark: placemark)
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
