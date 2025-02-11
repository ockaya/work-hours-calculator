//
//  WorkDayRowView.swift
//  Hours
//
//  Created by Ömer Cem Kaya on 11.02.2025.
//

import SwiftUI

struct WorkDayRowView: View {
    @ObservedObject var workDay: WorkDay  // @ObservedObject ekledik.
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Tarih ve gün adı
                if let date = workDay.date {
                    Text(date.formattedDate())
                        .font(.headline)
                    Text(date.dayName())
                        .font(.subheadline)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                if let clockIn = workDay.clockIn {
                    Text("Giriş: \(clockIn.formattedTime())")
                } else {
                    Text("Giriş: -")
                }
                if let clockOut = workDay.clockOut {
                    Text("Çıkış: \(clockOut.formattedTime())")
                } else {
                    Text("Çıkış: -")
                }
                // Hem giriş hem çıkış varsa toplam çalışma süresi hesaplanır.
                if let clockIn = workDay.clockIn, let clockOut = workDay.clockOut {
                    Text("Toplam: \(durationText(from: clockIn, to: clockOut))")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    /// İki tarih arasındaki süreyi "Xh Ym" formatında verir.
    private func durationText(from start: Date, to end: Date) -> String {
        let interval = end.timeIntervalSince(start)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct WorkDayRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Önizleme için dummy bir WorkDay oluşturuyoruz.
        let context = PersistenceController.shared.container.viewContext
        let workDay = WorkDay(context: context)
        workDay.date = Date()
        workDay.clockIn = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())
        workDay.clockOut = Calendar.current.date(bySettingHour: 17, minute: 30, second: 0, of: Date())
        
        return WorkDayRowView(workDay: workDay)
            .previewLayout(.sizeThatFits)
    }
}

