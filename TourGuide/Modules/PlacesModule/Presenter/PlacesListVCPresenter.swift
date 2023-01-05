//
//  PlacesListVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 27.12.2022.
//

import Foundation

protocol PlacesListVCPresenter {
    var places: Places? { get set }
    var placesProperties: [PlaceProperties] { get set }
    init(networkManager: NetworkManager, view: PlacesListController?)
    func viewShown()
    func getPlaceProperties(withID id: String, completion: @escaping (PlaceProperties?)->())
    func loadMoreData()
}

class PlacesListVCPresenterImpl: PlacesListVCPresenter {
    
    let networkManager: NetworkManager
    
    var places: Places?
    
    var placesProperties = [PlaceProperties]()
    
    weak var view: PlacesListController?
    
    required init(networkManager: NetworkManager, view: PlacesListController? = nil) {
        self.networkManager = networkManager
        self.view = view
    }
    
    func viewShown() {
        view?.setupViews()
        fetchData()
    }
    
    func fetchData() {
        let url = APIProvider.shared.placesURL()
        networkManager.fetchData(Places.self, forURL: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let place):
                self.places = place
                self.loadMoreData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadMoreData() {
        guard let view = view else { return }
        if !view.isLoading {
            if let places = places, placesProperties.count < places.features.count {
                view.isLoading = true
                let count = (places.features.count - placesProperties.count) >= 10 ? 10: (places.features.count - placesProperties.count)
                let group = DispatchGroup()
                for i in placesProperties.count..<(placesProperties.count+count) {
                    group.enter()
                    getPlaceProperties(withID: places.features[i].id ?? "") { [weak self] placeProperties in
                        if let placeProperties = placeProperties {
                            self?.placesProperties.append(placeProperties)
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    self.view?.reloadData()
                    view.isLoading = false
                }
            }
        }
    }

    func getPlaceProperties(withID id: String, completion: @escaping (PlaceProperties?)->()) {
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
    
}
