//
//  CityInfoCollectionViewCell.swift
//  weatherSharingApp
//
//  Created by user on 3/14/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit




class CityInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var savedDateLabel: UILabel!
    
    
    var buttonAction: emptyClosure?
    
    @IBAction func threeDotsAction(_ sender: UIButton) { buttonAction?() }
    
    override func didMoveToSuperview() {
        
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        guard let randomGradient = gradientColors.randomElement() else {
            UIView.insertGradient(in: gradientView, hexStrings: mainGradientColors)
            return
        }
        UIView.insertGradient(in: gradientView, hexStrings: randomGradient)
    }
    
}
