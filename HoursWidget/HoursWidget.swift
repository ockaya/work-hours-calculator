//
//  HoursWidget.swift
//  HoursWidget
//
//  Created by Ömer Cem KAYA on 11.02.2025.
//

import WidgetKit
import SwiftUI

@main
struct HoursWidget: Widget {
    let kind: String = "HoursWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HoursTimelineProvider()) { entry in
            HoursWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hours Widget")
        .description("Bugünkü clock in/out ve haftalık çalışma süresini gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

