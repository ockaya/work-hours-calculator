import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // Yeni eklenen preview property
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Dummy veriler oluşturabilirsiniz, örneğin:
        let calendar = Calendar.current
        let now = Date()
        for i in 0..<7 {
            let workDay = WorkDay(context: viewContext)
            workDay.date = calendar.date(byAdding: .day, value: i, to: now)
            workDay.clockIn = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: workDay.date!)!
            workDay.clockOut = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: workDay.date!)!
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return controller
    }()
    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Hours")
            
        // App Group kullanarak veritabanını paylaşalım.
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ock.Hours") {
            let storeURL = appGroupURL.appendingPathComponent("Hours.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        }
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Eğer uygulamada dummy veri eklemesi varsa, bunu burada yönetebilirsiniz.
        let context = container.viewContext
        let request: NSFetchRequest<WorkDay> = WorkDay.fetchRequest()
        if (try? context.count(for: request)) == 0 {
            self.generateDummyData(context: context)
        }
        
        if !self.isCurrentWeekAlreadyAdded(context: context) {
            self.addRecordsForCurrentWeek(context: context)
        }
    }
    
    private func isCurrentWeekAlreadyAdded(context: NSManagedObjectContext) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        guard let startOfWeek = today.startOfWeek() else { return false }
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        let request: NSFetchRequest<WorkDay> = WorkDay.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfWeek as NSDate, endOfWeek as NSDate)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error checking current week records: \(error)")
            return false
        }
    }
    
    private func addRecordsForCurrentWeek(context: NSManagedObjectContext) {
        let calendar = Calendar.current
        guard let startOfWeek = Date().startOfWeek() else { return }
        
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let workDay = WorkDay(context: context)
                workDay.date = dayDate
                // clockIn ve clockOut için herhangi bir değer vermiyoruz (nil kalacak)
                workDay.clockIn = nil
                workDay.clockOut = nil
            }
        }
        
        do {
            try context.save()
            print("Current week records added successfully.")
        } catch {
            print("Error saving current week records: \(error)")
        }
    }

    /// İki haftalık dummy veri oluşturma fonksiyonu (isteğe bağlı)
    func generateDummyData(context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let now = Date()
        // Haftanın başlangıcını (pazartesi) buluyoruz.
        var components = calendar.dateComponents([.year, .month, .day, .weekday], from: now)
        let weekday = components.weekday!  // Sunday=1, Monday=2, ...
        let offset = (weekday + 5) % 7
        guard let lastMonday = calendar.date(byAdding: .day, value: -offset, to: now) else { return }
        
        for i in 0..<14 {
            let dayDate = calendar.date(byAdding: .day, value: i, to: lastMonday)!
            let workDay = WorkDay(context: context)
            workDay.date = dayDate
            if !calendar.isDateInWeekend(dayDate) {
//                workDay.clockIn = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dayDate)!
                workDay.clockIn = nil
//                workDay.clockOut = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: dayDate)!
                workDay.clockOut = nil
            } else {
                workDay.clockIn = nil
                workDay.clockOut = nil
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Dummy veri kaydedilirken hata: \(error)")
        }
    }
}
