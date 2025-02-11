//
//  WorkDay.swift
//  Hours
//
//  Created by Ömer Cem Kaya on 11.02.2025.
//

import Foundation
import CoreData

@objc(WorkDay)
public class WorkDay: NSManagedObject { }

extension WorkDay {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkDay> {
        return NSFetchRequest<WorkDay>(entityName: "WorkDay")
    }

    @NSManaged public var date: Date?
    @NSManaged public var clockIn: Date?
    @NSManaged public var clockOut: Date?
}

extension WorkDay: Identifiable { }

