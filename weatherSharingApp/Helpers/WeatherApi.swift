//
//  WeatherApi.swift
//  WeatherLoader
//
//  Created by user on 2/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import Foundation




struct Api {
    
    static let baseUrlString = "http://api.openweathermap.org/data/2.5/"
    static let forecastEndPoint = "forecast?"
    static let appId = "&appId=9bf746618f86e9235fe0914628e0132b"
    static let weatherUnit = "&units=metric"
    static let baseImageUrlString = "http://openweathermap.org/img/w/"
    static let imageExtension = ".png"
}

class WeatherApi {
   
    static func getCityWeatherByName(_ name: String, onSuccess: @escaping(Data) -> Void, onError: @escaping(Int) -> Void) {
        
        let completeUrlString = Api.baseUrlString + Api.forecastEndPoint + "q=\(name)" + Api.appId + Api.weatherUnit
    
        guard let url = URL.init(string: completeUrlString) else { return }
        
        downloader.loadData(fromUrl: url) { (result) in
            
            let resultData = downloader.handleRequestedResult(result: result)
            switch resultData {
                
            case let errorCode as Int:
                onError(errorCode)
                
            case let data as Data:
                onSuccess(data)
                
            default: break
            }
        }
    }
    
    static func getWeatherIcon(by name: String, onSuccess: @escaping(Data) -> Void, onError: @escaping(Int) -> Void) {
        
        let fullImageUrlString = Api.baseImageUrlString + name + Api.imageExtension
        guard let url = URL.init(string: fullImageUrlString) else { return }
        
        downloader.loadImage(fromUrl: url) { (result) in
            
            let resultData = downloader.handleRequestedResult(result: result)
            switch resultData {
                
            case let errorCode as Int:
                onError(errorCode)
                
            case let data as Data:
                onSuccess(data)
                
            default: break
            }
        }
    }
}
