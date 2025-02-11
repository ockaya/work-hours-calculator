//
//  WorkDayEditView.swift
//  Hours
//
//  Created by Ömer Cem Kaya on 11.02.2025.
//

import SwiftUI

struct WorkDayEditView: View {
    @ObservedObject var workDay: WorkDay
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var clockIn: Date
    @State private var clockOut: Date
    @State private var showDeleteConfirmation = false

    init(workDay: WorkDay) {
        self.workDay = workDay
        let day = workDay.date ?? Date()
        // Eğer clockIn nil ise o gün için varsayılan 09:00
        let defaultClockIn = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: day)!
        // Eğer clockOut nil ise o gün için varsayılan 18:00
        let defaultClockOut = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: day)!
        _clockIn = State(initialValue: workDay.clockIn ?? defaultClockIn)
        _clockOut = State(initialValue: workDay.clockOut ?? defaultClockOut)
    }

    var body: some View {
        Form {
            Section(header: Text("Giriş Saati")) {
                DatePicker("Giriş", selection: $clockIn, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
            }
            Section(header: Text("Çıkış Saati")) {
                DatePicker("Çıkış", selection: $clockOut, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
            }
            // Kaydet Butonu
            Button("Kaydet") {
                saveChanges()
            }
            .padding()
            .foregroundColor(.blue)
            
            // Sil Butonu: Bu buton clockIn ve clockOut verilerini temizleyecek.
            Button("Sil") {
                showDeleteConfirmation = true
            }
            .padding()
            .foregroundColor(.red)
        }
        .navigationTitle("Saatleri Düzenle")
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Silme Onayı"),
                message: Text("Bu güne ait tüm saat verilerini silmek istediğinizden emin misiniz?"),
                primaryButton: .destructive(Text("Sil")) {
                    deleteData()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    /// Kaydetme işlemi: Düzenlenen clockIn ve clockOut verilerini workDay'e aktarıp Core Data'yı kaydediyoruz.
    private func saveChanges() {
        workDay.clockIn = clockIn
        workDay.clockOut = clockOut
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Saatler kaydedilemedi: \(error)")
        }
    }
    
    /// Silme işlemi: clockIn ve clockOut değerlerini nil yapıp kaydediyoruz.
    private func deleteData() {
        workDay.clockIn = nil
        workDay.clockOut = nil
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Veriler silinemedi: \(error)")
        }
    }
}

struct WorkDayEditView_Previews: PreviewProvider {
    static var previews: some View {
        // Önizleme için in-memory context kullanalım.
        let context = PersistenceController.preview.container.viewContext
        let workDay = WorkDay(context: context)
        workDay.date = Date()
        workDay.clockIn = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())
        workDay.clockOut = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())
        return NavigationView {
            WorkDayEditView(workDay: workDay)
                .environment(\.managedObjectContext, context)
        }
    }
}


