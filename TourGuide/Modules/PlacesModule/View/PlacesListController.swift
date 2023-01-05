//
//  PlacesListController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import UIKit

protocol PlacesListController: AnyObject {
    var isLoading: Bool { get set }
    func setupViews()
    func reloadData()
}

class PlacesListControllerImpl: UIViewController, PlacesListController {
    
    var presenter: PlacesListVCPresenter?
    
    var isLoading = false
    
    private var collectionView: UICollectionView?
    
    private lazy var footerActivityIndicator: UIActivityIndicatorView = {
        let actInd = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        actInd.translatesAutoresizingMaskIntoConstraints = false
        actInd.hidesWhenStopped = true
        return actInd
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshCntrl = UIRefreshControl()
        return refreshCntrl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewShown()
    }
    
    func setupViews() {
        let view = UIView()
        view.frame = self.view.frame
                
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 18, bottom: 20, right: 18)
        layout.itemSize = CGSize(width: view.frame.size.width - 36, height: view.frame.size.height/2 - 150)
        layout.footerReferenceSize = CGSize(width: view.frame.width, height: 55)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20;
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView?.register(PlaceCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView?.register(
            LoadingReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "Footer"
        )
        collectionView?.backgroundColor = .systemBackground
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(updateData(_:)), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        view.addSubview(collectionView!)
            
        self.view = view
    }
    
    @objc
    private func updateData(_ sender: Any) {
        self.collectionView?.reloadData()
        refreshControl.endRefreshing()
    }
    
    func reloadData() {
        self.collectionView?.reloadData()
    }

}


// MARK: Delegate
extension PlacesListControllerImpl: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter?.placesProperties.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PlaceCell
            
        myCell.place = presenter?.placesProperties[indexPath.item]
            
        return myCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: view.frame.width, height: 55)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! LoadingReusableView
            aFooterView.backgroundColor = UIColor.clear
            aFooterView.addSubview(footerActivityIndicator)
            footerActivityIndicator.topAnchor.constraint(equalTo: aFooterView.topAnchor).isActive = true
            footerActivityIndicator.centerXAnchor.constraint(equalTo: aFooterView.centerXAnchor).isActive = true
            return aFooterView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerActivityIndicator.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerActivityIndicator.stopAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let presenter = presenter, indexPath.item == (presenter.placesProperties.count - 1) {
            presenter.loadMoreData()
        }
    }
    
}
