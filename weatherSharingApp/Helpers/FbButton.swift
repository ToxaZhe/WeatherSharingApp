//
//  FbButton.swift
//  weatherSharingApp
//
//  Created by user on 3/7/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit
import FacebookLogin



class FbButton: UIButton {
    let bgColor = "38559D"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customize()
    }
    
    func customize() {
        layer.backgroundColor = UIColor(hexString: bgColor).cgColor
        layer.cornerRadius = self.frame.width * 0.08
    }
}

