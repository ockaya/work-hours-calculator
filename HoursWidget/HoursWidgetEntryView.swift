//
//  HoursWidgetEntryView.swift
//  Hours
//
//  Created by Ömer Cem KAYA on 11.02.2025.
//

import SwiftUI
import WidgetKit
import CoreData

struct HoursWidgetEntryView: View {
    var entry: HoursTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Saat bilgilerini gösterelim.
            VStack(alignment: .leading, spacing: 4) {
                Text("Giriş: \(entry.clockIn != nil ? entry.clockIn!.formattedTime() : "-")")
                if let clockOut = entry.clockOut {
                    Text("Çıkış: \(clockOut.formattedTime())")
                } else if let clockIn = entry.clockIn {
                    // Çıkış yapılmadıysa, clockIn’den itibaren geçen süreyi hesaplayalım.
                    let elapsed = Date().timeIntervalSince(clockIn)
                    let hours = Int(elapsed) / 3600
                    let minutes = (Int(elapsed) % 3600) / 60
                    Text("Geçen Süre: \(hours)h \(minutes)m")
                } else {
                    Text("Geçen Süre: -")
                }
            }
            .font(.caption)
            
            // Interaktif Buton
            Button(action: {
                handleButtonTap()
            }) {
                Text(buttonTitle())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(buttonDisabled())
            
            Spacer()
            
            // Haftalık toplam çalışma süresi
            HStack {
                Spacer()
                let weekTotalSeconds = entry.weekTotal
                let hours = Int(weekTotalSeconds) / 3600
                let minutes = (Int(weekTotalSeconds) % 3600) / 60
                Text("\(hours)h \(minutes)m")
                    .font(.footnote)
            }
        }
        .padding()
    }
    
    /// Buton başlığı: Eğer clock in yapılmamışsa “Clock In”, yapılmışsa ve clock out eksikse “Clock Out”, her ikisi varsa “Tamamlandı”
    func buttonTitle() -> String {
        if entry.clockIn == nil {
            return "Clock In"
        } else if entry.clockOut == nil {
            return "Clock Out"
        } else {
            return "Tamamlandı"
        }
    }
    
    func buttonDisabled() -> Bool {
        return entry.clockIn != nil && entry.clockOut != nil
    }
    
    /// Butona tıklandığında Core Data’daki WorkDay kaydını güncelleyen interaktif aksiyon.
    func handleButtonTap() {
        print("handleButtonTap")
        let now = Date()
        let persistenceController = PersistenceController.shared
        let context = persistenceController.container.viewContext
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let request: NSFetchRequest<WorkDay> = WorkDay.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1
        do {
            let results = try context.fetch(request)
            let workDay = results.first ?? WorkDay(context: context)
            // Eğer workDay.date boşsa bugünü ata.
            if workDay.date == nil {
                workDay.date = now
            }
            if workDay.clockIn == nil {
                workDay.clockIn = now
            } else if workDay.clockOut == nil {
                workDay.clockOut = now
            }
            try context.save()
            // Güncellemeden sonra widget’ları yenileyelim.
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Button action error: \(error)")
        }
    }
}

struct HoursWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEntry = HoursEntry(
            date: Date(),
            clockIn: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
            clockOut: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()),
            weekTotal: 9 * 3600 + 30 * 60  // example: 9 hours 30 minutes
        )
        HoursWidgetEntryView(entry: sampleEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

