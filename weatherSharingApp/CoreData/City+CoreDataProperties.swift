//
//  City+CoreDataProperties.swift
//  weatherSharingApp
//
//  Created by user on 3/13/18.
//  Copyright © 2018 Toxa. All rights reserved.
//
//

import Foundation
import CoreData

extension City {
    
    static var defaultCitySortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "createdUpdated", ascending: false)]
    }
}

extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var createdUpdated: NSDate?
    @NSManaged public var user: User?
    @NSManaged public var weatherForecasts: NSSet?

}

// MARK: Generated accessors for weatherForecasts
extension City {

    @objc(addWeatherForecastsObject:)
    @NSManaged public func addToWeatherForecasts(_ value: WeatherForecast)

    @objc(removeWeatherForecastsObject:)
    @NSManaged public func removeFromWeatherForecasts(_ value: WeatherForecast)

    @objc(addWeatherForecasts:)
    @NSManaged public func addToWeatherForecasts(_ values: NSSet)

    @objc(removeWeatherForecasts:)
    @NSManaged public func removeFromWeatherForecasts(_ values: NSSet)

}
