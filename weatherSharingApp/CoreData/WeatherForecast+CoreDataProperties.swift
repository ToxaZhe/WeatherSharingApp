//
//  WeatherForecast+CoreDataProperties.swift
//  weatherSharingApp
//
//  Created by user on 3/13/18.
//  Copyright © 2018 Toxa. All rights reserved.
//
//

import Foundation
import CoreData

extension WeatherForecast {
    
    static var defaultWeatherSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdAt", ascending: true)]
    }
}

extension WeatherForecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherForecast> {
        return NSFetchRequest<WeatherForecast>(entityName: "WeatherForecast")
    }

    @NSManaged public var createdAt: Double
    @NSManaged public var dayTime: String?
    @NSManaged public var maxTemp: String?
    @NSManaged public var minTemp: String?
    @NSManaged public var weatherDescription: String?
    @NSManaged public var weatherImg: NSData?
    @NSManaged public var city: City?

}
