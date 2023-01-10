//
//  PlaceImageCell.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 07.01.2023.
//

import UIKit

class PlaceImageCell: UITableViewCell {
    
    static let cellId = "ImageCell"
    
    var delegate: PlaceDetailsPresenterDelegate?
    
    var imageURL: String? {
        didSet {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                placeImage.load(url: url)
            }
        }
    }
    
    private var placeImage: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName: SystemSymbol.places.rawValue))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private var routeImage: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName: SystemSymbol.paperplaneCircle.rawValue))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 0.9)
        imgView.layer.cornerRadius = 100 / 2
        imgView.clipsToBounds = true
        return imgView
    }()
    
    @objc
    private func makeRoute(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: routeImage)
        if point.x >= 0 && point.y >= 0 {
            delegate?.makeRoute()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(placeImage)
        addSubview(routeImage)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(makeRoute(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        placeImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        placeImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        placeImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        placeImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        placeImage.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        placeImage.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        routeImage.trailingAnchor.constraint(equalTo: placeImage.trailingAnchor, constant: -10).isActive = true
        routeImage.bottomAnchor.constraint(equalTo: placeImage.bottomAnchor, constant: 20).isActive = true
        routeImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        routeImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder init isn't implemented")
    }

}
