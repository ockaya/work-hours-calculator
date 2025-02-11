//
//  Date+Extensions.swift
//  Hours
//
//  Created by Ömer Cem Kaya on 11.02.2025.
//

import Foundation

import Foundation

extension Date {
    /// Tarihin ait olduğu haftanın başlangıcını (pazartesi) döner.
    func startOfWeek() -> Date? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Pazartesi
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)
    }
    
    /// 24 saat formatında saat gösterimi (HH:mm)
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// Günün tarihi (ör. "24 Feb 2025")
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self)
    }
    
    /// Gün adı kısaltması (örn. Mon, Tue, vs.)
    func dayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }
}

