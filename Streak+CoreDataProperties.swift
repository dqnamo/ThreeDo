//
//  Streak+CoreDataProperties.swift
//  ThreeDo (iOS)
//
//  Created by John Paul on 17/03/2021.
//

import Foundation
import CoreData


extension Streak: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Streak> {
        return NSFetchRequest<Streak>(entityName: "Streak")
    }

    @NSManaged public var counter: Int64
    @NSManaged public var date: Date

}
