//
//  DialogHelper.swift
//  WeatherLoader
//
//  Created by user on 2/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import Foundation
import UIKit


class DialogHelper {
    
    static func showAlert(title: String, message: String?, controller: UIViewController, handleAction: (() -> Void )?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            handleAction?()
        }
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
}
