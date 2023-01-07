//
//  PlaceDetailPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 07.01.2023.
//

import Foundation

protocol PlaceDetailsPresenter {
    var router: Router? { get }
    var placeProperties: PlaceProperties? { get }
    init(place: Feature?, networkManager: NetworkManager?, view: PlaceDetailsController?, router: Router?)
    func viewShown()
}

class PlaceDetailsPresenterImpl: PlaceDetailsPresenter {
    
    var router: Router?
    
    var placeProperties: PlaceProperties?
    
    private var place: Feature?
    
    private var view: PlaceDetailsController?
    
    private var networkManager: NetworkManager?
    
    required init(place: Feature?, networkManager: NetworkManager?, view: PlaceDetailsController?, router: Router?) {
        self.place = place
        self.router = router
        self.view = view
        self.networkManager = networkManager
    }
    
    func viewShown() {
        view?.setupViews()
        if let id = place?.id {
            getPlaceProperties(withID: id) { placeProp in
                self.placeProperties = placeProp
                self.view?.reloadData()
            }
        }
    }
    
    private func getPlaceProperties(withID id: String, completion: @escaping (PlaceProperties?)->()) {
        let url = APIProvider.shared.propertiesOfObjectURL(withId: id)
        networkManager?.fetchData(PlaceProperties.self, forURL: url) { result in
            switch result {
            case .success(let prop):
                completion(prop)
            case .failure(let error):
                completion(nil)
                print(error)
            }
        }
    }
    
    
}
