//
//  HoursTimelineProvider.swift
//  Hours
//
//  Created by Ömer Cem KAYA on 11.02.2025.
//

import WidgetKit
import CoreData
import SwiftUI

struct HoursTimelineProvider: TimelineProvider {
    let persistenceController = PersistenceController.shared

    func placeholder(in context: Context) -> HoursEntry {
        HoursEntry(date: Date(), clockIn: nil, clockOut: nil, weekTotal: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (HoursEntry) -> Void) {
        let entry = fetchCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HoursEntry>) -> Void) {
        let entry = fetchCurrentEntry()
        // Timeline policy .never; interaktif buton aksiyonuyla güncelleme sağlandıktan sonra WidgetCenter.reloadTimelines() çağrılacak.
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    private func fetchCurrentEntry() -> HoursEntry {
        let now = Date()
        let todayRecord = fetchTodayRecord()  // Bugüne ait WorkDay kaydı
        let weekTotal = calculateWeekTotal()
        return HoursEntry(date: now,
                          clockIn: todayRecord?.clockIn,
                          clockOut: todayRecord?.clockOut,
                          weekTotal: weekTotal)
    }
    
    private func fetchTodayRecord() -> WorkDay? {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<WorkDay> = WorkDay.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Fetch error: \(error)")
            return nil
        }
    }
    
    private func calculateWeekTotal() -> TimeInterval {
        let context = persistenceController.container.viewContext
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = now.startOfWeek() else { return 0 }
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        let request: NSFetchRequest<WorkDay> = WorkDay.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfWeek as NSDate, endOfWeek as NSDate)
        do {
            let days = try context.fetch(request)
            let totalSeconds = days.reduce(0) { (sum, day) -> TimeInterval in
                if let clockIn = day.clockIn, let clockOut = day.clockOut {
                    return sum + clockOut.timeIntervalSince(clockIn)
                }
                return sum
            }
            return totalSeconds
        } catch {
            print("Week total fetch error: \(error)")
            return 0
        }
    }
}
