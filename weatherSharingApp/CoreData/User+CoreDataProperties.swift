//
//  User+CoreDataProperties.swift
//  weatherSharingApp
//
//  Created by user on 3/13/18.
//  Copyright © 2018 Toxa. All rights reserved.
//
//

import Foundation
import CoreData

extension User {
    
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
    
    static var sortedFetchRequest: NSFetchRequest<User> {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.sortDescriptors = User.defaultSortDescriptors
        return request
    }
    
}

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var cities: NSSet?

}

// MARK: Generated accessors for cities
extension User {

    @objc(addCitiesObject:)
    @NSManaged public func addToCities(_ value: City)

    @objc(removeCitiesObject:)
    @NSManaged public func removeFromCities(_ value: City)

    @objc(addCities:)
    @NSManaged public func addToCities(_ values: NSSet)

    @objc(removeCities:)
    @NSManaged public func removeFromCities(_ values: NSSet)

}
