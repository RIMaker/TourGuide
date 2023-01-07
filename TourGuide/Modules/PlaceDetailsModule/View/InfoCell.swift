//
//  InfoCell.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 07.01.2023.
//

import UIKit

class InfoCell: UITableViewCell {

    static let cellId = "InfoCell"
    
    var info: (String, String?)? {
        didSet {
            label.text = info?.0
            infoLabel.text = info?.1 ?? "Информация отсутствует."
        }
    }
    
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 20)
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        addSubview(infoLabel)
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        infoLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder init isn't implemented")
    }

}
