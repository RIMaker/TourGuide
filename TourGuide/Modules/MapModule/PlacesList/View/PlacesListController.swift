//
//  PlacesListController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import UIKit

protocol PlacesListController {
    
}

class PlacesListControllerImpl: UIViewController, PlacesListController {
    
    var collectionView: UICollectionView?
    
    var places: Place?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
        let view = UIView()
        view.frame = self.view.frame
        view.backgroundColor = .white
                
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 18, bottom: 20, right: 18)
        layout.itemSize = CGSize(width: view.frame.size.width/2 - 30, height: view.frame.size.height/2 - 150)
            
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        view.addSubview(collectionView ?? UICollectionView())
            
        self.view = view
    }
    
    func fetchData() {
        let networkManager = NetworkManagerImpl()
        networkManager.fetchData(Place.self, forURL: APIProvider.shared.placesURL()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let place):
                self.places = place
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

}

extension PlacesListControllerImpl: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        places?.features.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        myCell.backgroundColor = UIColor.blue
        
        return myCell
    }
    
}
