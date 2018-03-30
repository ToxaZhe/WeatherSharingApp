//
//  CityWeather.swift
//  WeatherLoader
//
//  Created by user on 2/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import Foundation

struct CityWeather: Decodable {
    let cnt: Int
    let list: [WeatherInfo]
    let city: CityInfo
}

extension CityWeather {
    struct CityInfo: Decodable {
        let name: String
    }
}


extension CityWeather {
    struct WeatherInfo: Decodable {
        let dt: Double
        let dt_txt: String
        let weather: [Weather]
        var main: MainWeatherInfo
        let sys: Sys
    }
}


extension CityWeather {
    
    struct Weather: Decodable {
        let main: String
        let icon: String
    }
    
    struct Sys: Decodable {
        let pod : String
    }
}

extension CityWeather {
    
    struct MainWeatherInfo: Decodable {
        var temp_min: Double
        var temp_max: Double
    }
}
