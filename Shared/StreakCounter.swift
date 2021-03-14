//
//  StreakCounter.swift
//  ThreeDo
//
//  Created by John Paul on 13/03/2021.
//

import SwiftUI
import CoreData

struct StreakCounter: View {
    @State private var today: Date = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var streakCount: Int = 0
    
    var body: some View {
        HStack(spacing: 0){
            if findCount(day: previousDate(day: today)) == 0{
                Text("0 ❄️")
            }else{
                Text("\(findCount(day: previousDate(day: today))) 🔥")
            }
//            Text("🔥")
//            Image(systemName: "\(findCount(day: today)).circle.fill")
//                .font(.system(size: 20))
//                .foregroundColor(.orange)
//            Text("\(findCount(day: today)) 🔥")
        }
    }
    
    private func findCount(day: Date) -> Int{
        var count = 0
        let tasksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        tasksFetch.predicate = fetchPredicate(filter: day)
        
        
        if getRequestCount(request: tasksFetch) != 3{
            return 0
        }else{
            count += 1
            count = count + findCount(day: previousDate(day: day))
        }

        
//        self.streakCount = count
        return count
    }
    
    private func previousDate(day: Date) -> Date{
        return day.addingTimeInterval(-86400)
    }
    
    private func getRequestCount(request: NSFetchRequest<NSFetchRequestResult>) -> Int{
        do{
            return try viewContext.count(for: request)
        } catch {
            return 0
        }
    }
    
    private func fetchPredicate(filter: Date) -> NSPredicate{
        // get the current calendar
        let calendar = NSCalendar.current
        // get the start of the day of the selected date
        let startDate = calendar.startOfDay(for: filter)
        // get the start of the day after the selected date
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = calendar.date(byAdding: components, to: startDate)!
        // create a predicate to filter between start date and end date
        let predicate = NSPredicate(format: "date >= %@ AND date < %@ AND completed = %@", startDate as NSDate, endDate as NSDate, NSNumber(value: true))
        
        return predicate
    }
}
