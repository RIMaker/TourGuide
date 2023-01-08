//
//  PlaceDetailController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 07.01.2023.
//

import UIKit
import MapKit

protocol PlaceDetailsController {
    func setupViews()
    func reloadData()
}

class PlaceDetailsControllerImpl: UIViewController, PlaceDetailsController {
    
    var presenter: PlaceDetailsPresenter?
    
    private var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewShown()
    }
    
    func setupViews() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Информация об объекте"
        let view = UIView()
        view.frame = self.view.frame
        
        tableView = UITableView(frame: view.frame)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(PlaceImageCell.self, forCellReuseIdentifier: PlaceImageCell.cellId)
        tableView?.register(InfoCell.self, forCellReuseIdentifier: InfoCell.cellId)
        tableView?.backgroundColor = .systemBackground
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 500
        tableView?.separatorStyle = .none
        
        view.addSubview(tableView!)
            
        self.view = view
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
}


extension PlaceDetailsControllerImpl: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaceImageCell.cellId, for: indexPath) as! PlaceImageCell
            cell.selectionStyle = .none
            cell.imageURL = presenter?.placeProperties?.preview?.source
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.cellId, for: indexPath) as! InfoCell
            cell.info = ("НАЗВАНИЕ", presenter?.placeProperties?.name)
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.cellId, for: indexPath) as! InfoCell
            if let address = presenter?.placeProperties?.address {
                var addressArr = [address.city ?? "", address.road ?? "", address.houseNumber ?? ""]
                addressArr = addressArr.filter { $0 != "" }
                cell.info = ("АДРЕС", addressArr.joined(separator: ", "))
            }
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.cellId, for: indexPath) as! InfoCell
            if let lat = presenter?.placeProperties?.point?.lat, let lon = presenter?.placeProperties?.point?.lon {
                let placeMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                cell.info = ("РАССТОЯНИЕ ОТ ВАС", presenter?.distanceToUser(fromPlace: MKMapItem(placemark: placeMark)))
            } else {
                cell.info = ("РАССТОЯНИЕ ОТ ВАС", nil)
            }
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.cellId, for: indexPath) as! InfoCell
            cell.info = ("ОПИСАНИЕ",presenter?.placeProperties?.wikipediaExtracts?.text)
            cell.selectionStyle = .none
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
}
