import SwiftUI
import CoreData
import UIKit

struct ContentView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkDay.date, ascending: true)],
        animation: .default)
    private var workDays: FetchedResults<WorkDay>
    
    // Toast state variables
    @State private var showToast: Bool = false
    @State private var toastText: String = ""
    
    var body: some View {
        NavigationView {
            List {
                // Weeks in descending order
                ForEach(groupedByWeek.keys.sorted(by: >), id: \.self) { weekKey in
                    Section(header: headerView(for: weekKey)) {
                        ForEach(groupedByWeek[weekKey] ?? []) { workDay in
                            NavigationLink(destination: WorkDayEditView(workDay: workDay)) {
                                WorkDayRowView(workDay: workDay)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Hours")
        }
        // Overlay for the toast message
        .overlay(
            Group {
                if showToast {
                    ToastView(message: toastText)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showToast)
                }
            },
            alignment: .top
        )
    }
    
    // Group the WorkDay records by the week start (Monday)
    private var groupedByWeek: [Date: [WorkDay]] {
        let groups = Dictionary(grouping: workDays, by: { workDay -> Date in
            let date = workDay.date ?? Date()
            return date.startOfWeek() ?? date
        })
        return groups
    }
    
    // Returns a formatted week range string like "17 - 23 Feb 2025"
    private func weekRangeText(for monday: Date) -> String {
        let calendar = Calendar.current
        // Sunday = Monday + 6 days
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "MMM yyyy"
        
        let mondayDay = dayFormatter.string(from: monday)
        let sundayDay = dayFormatter.string(from: sunday)
        let monthYear = monthYearFormatter.string(from: monday)
        return "\(mondayDay) - \(sundayDay) \(monthYear)"
    }
    
    // Builds the header view that displays the week range, total worked time, and a copy button.
    private func headerView(for monday: Date) -> some View {
        HStack {
            Text(weekRangeText(for: monday))
                .font(.headline)
            Spacer()
            Text(totalWorkedTime(for: groupedByWeek[monday] ?? []))
            Button(action: { copyWeekData(for: monday) }) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
    
    // Calculates the total worked time for a list of WorkDay records.
    private func totalWorkedTime(for workDays: [WorkDay]) -> String {
        let totalSeconds = workDays.reduce(0) { result, workDay in
            if let clockIn = workDay.clockIn, let clockOut = workDay.clockOut {
                return result + clockOut.timeIntervalSince(clockIn)
            }
            return result
        }
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    // Generates the week data string in the desired format and copies it to the clipboard.
    // Also shows a toast message "Copied!".
    private func copyWeekData(for monday: Date) {
        guard let weekRecords = groupedByWeek[monday] else { return }
        // Sort the records by date ascending (Monday to Sunday)
        let sortedRecords = weekRecords.sorted {
            guard let date1 = $0.date, let date2 = $1.date else { return false }
            return date1 < date2
        }
        
        // Start with the week range header
        var output = "\(weekRangeText(for: monday))\n"
        let calendar = Calendar.current
        
        // Iterate through Monday (i=0) to Sunday (i=6)
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: monday) {
                // Find the record matching the current day
                let record = sortedRecords.first(where: { calendar.isDate($0.date ?? Date(), inSameDayAs: dayDate) })
                // Get the abbreviated day name (e.g., "Mon", "Tue", etc.)
                let weekdayIndex = calendar.component(.weekday, from: dayDate) - 1
                let dayAbbrev = DateFormatter().shortWeekdaySymbols[weekdayIndex]
                
                let clockInStr = record?.clockIn != nil ? record!.clockIn!.formattedTime() : "x"
                let clockOutStr = record?.clockOut != nil ? record!.clockOut!.formattedTime() : "x"
                output += "\(dayAbbrev) => \(clockInStr), \(clockOutStr)\n"
            }
        }
        // Copy the generated string to the clipboard
        UIPasteboard.general.string = output
        
        // Show toast message "Copied!"
        self.toastText = "Copied!"
        withAnimation {
            self.showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showToast = false
            }
        }
    }
}

// A simple Toast view that appears at the top.
struct ToastView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.top, 20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
