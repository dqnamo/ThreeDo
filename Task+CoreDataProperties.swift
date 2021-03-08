//
//  Task+CoreDataProperties.swift
//  ThreeDo (iOS)
//
//  Created by John Paul on 08/03/2021.
//
//

import Foundation
import CoreData


extension Task: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var name: String
    @NSManaged public var id: UUID?

}
