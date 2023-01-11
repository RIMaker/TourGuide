//
//  PlaceCell.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 18.12.2022.
//

import UIKit

class PlaceCell: UICollectionViewCell {
    
    static let cellIdentifier = "Cell"
    
    var place: Feature? {
        didSet {
            if let place = place {
                DispatchQueue.main.async { [weak self] in
                    self?.nameLabel.text = place.properties?.name
                }
            }
        }
    }
    
    var distanceToUser: String? {
        didSet {
            if let distanceToUser = distanceToUser {
                DispatchQueue.main.async { [weak self] in
                    self?.distanceLabel.text = "\(distanceToUser) км."
                }
            }
        }
    }
    
    private var imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.image = UIImage(systemName: SystemSymbol.paperplane.rawValue)
        img.layer.cornerRadius = 12
        return img
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 2
        lbl.text = ""
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        return lbl
    }()
    
    private let distanceLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = ""
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 15)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(distanceLabel)
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.frame.height * 0.25).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentView.frame.width * 0.8).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentView.frame.height * 0.25).isActive = true
        
        nameLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -10).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        nameLabel.topAnchor.constraint(equalTo:  contentView.topAnchor, constant: 15).isActive = true
        
        distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        distanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 4.0, height: 2.0)
        contentView.layer.shadowRadius = 2.0
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.masksToBounds = false
        
        contentView.layer.shadowPath = UIBezierPath(
            roundedRect: contentView.bounds,
            cornerRadius: contentView.layer.cornerRadius
        ).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder) is not implemented")
    }
    
}
