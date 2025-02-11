import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkDay.date, ascending: true)],
        animation: .default)
    private var workDays: FetchedResults<WorkDay>
    
    var body: some View {
        NavigationView {
            List {
                // WorkDay kayıtlarını haftanın başlangıcına göre gruplandırıyoruz.
                ForEach(groupedByWeek.keys.sorted(), id: \.self) { weekKey in
                    Section(header:
                        HStack {
                            Text("Hafta: \(weekHeader(for: weekKey))")
                            Spacer()
                            Text(totalWorkedTime(for: groupedByWeek[weekKey] ?? []))
                        }
                    ) {
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
    }
    
    /// WorkDay kayıtlarını haftanın başlangıcına (pazartesi) göre gruplandırır.
    private var groupedByWeek: [Date: [WorkDay]] {
        let groups = Dictionary(grouping: workDays, by: { workDay -> Date in
            let date = workDay.date ?? Date()
            return date.startOfWeek() ?? date
        })
        return groups
    }
    
    /// Haftanın başlangıcını (pazartesi) okunabilir formatta verir.
    private func weekHeader(for monday: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: monday)
    }
    
    /// Belirtilen haftadaki günler için toplam çalışma süresini hesaplar.
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
