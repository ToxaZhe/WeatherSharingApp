//
//  WeatherCollectionViewCell.swift
//  weatherSharingApp
//
//  Created by user on 3/13/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var dayTimeLabel: UILabel!
    @IBOutlet weak var minMaxTempLbl: UILabel!
    @IBOutlet weak var weatherDescriptionLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
//    var weatherForecasts: (WeatherForecast, WeatherForecast)!
    
    override func didMoveToSuperview() {
        cardBackgroundView.apply(andRadius: 16)
    }
}
