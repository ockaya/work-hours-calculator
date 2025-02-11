//
//  TimelineEntry.swift
//  Hours
//
//  Created by Ömer Cem KAYA on 11.02.2025.
//

import WidgetKit
import Foundation

struct HoursEntry: TimelineEntry {
    let date: Date
    let clockIn: Date?
    let clockOut: Date?
    let weekTotal: TimeInterval
}
