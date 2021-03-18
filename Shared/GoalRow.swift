//
//  GoalRow.swift
//  ThreeDo
//
//  Created by John Paul on 10/03/2021.
//

import Foundation
import CoreData
import SwiftUI
import AVFoundation

struct GoalRow: View {
    @ObservedObject var task: Task
    @State var locked: Bool = false
    @State var past: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack {
            if past{
                VStack(alignment: .leading){
                    Text("\(task.name)")
                    Text("\(displayDate(day: task.date))").foregroundColor(Color.gray)
                        .fontWeight(.regular)
                        .font(.system(size: 14))
                }
            }else{
                Text("\(task.name)")
            }
            Spacer()
            if task.completed{
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
            }
            if !task.completed && past{
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
            }
        }
        .onTapGesture(count: 1) {
            if locked{ return }
            
            if task.completed{
                uncompleteTodo(t: task)
            }else{
                completeTodo(t: task)
            }
        }
    }
    
    private func completeTodo(t: Task){
        t.completed = true
        do {
            try viewContext.save()
            AudioServicesPlaySystemSound(4095)
        } catch {
            print("error")
        }
        
        createStreakRecord(task: t)
    }
    
    private func createStreakRecord(task: Task){
        let streakFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Streak")
        
        let calendar = NSCalendar.current
        // get the start of the day of the selected date
        let startDate = calendar.startOfDay(for: task.date)
        // get the start of the day after the selected date
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = calendar.date(byAdding: components, to: startDate)!
        
        streakFetch.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        streakFetch.fetchLimit = 1
        
        if getRequestCount(request: streakFetch) == 0{
            let streak = Streak(context: viewContext)
            streak.date = task.date
            
            let tasksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            
            let calendar = NSCalendar.current
            // get the start of the day of the selected date
            let startDate = calendar.startOfDay(for: task.date)
            // get the start of the day after the selected date
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let endDate = calendar.date(byAdding: components, to: startDate)!
            // create a predicate to filter between start date and end date
            tasksFetch.predicate = NSPredicate(format: "date >= %@ AND date < %@ AND completed == %@", startDate as NSDate, endDate as NSDate, NSNumber(value: true))
            
            if getRequestCount(request: tasksFetch) == 3{
                let calendar = NSCalendar.current
                // get the start of the day of the selected date
                let startDate = calendar.startOfDay(for: previousDate(day: streak.date))
                // get the start of the day after the selected date
                var components = DateComponents()
                components.day = 1
                components.second = -1
                let endDate = calendar.date(byAdding: components, to: startDate)!
                
                streakFetch.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
                
                
                if getRequestCount(request: streakFetch) != 0{
                    do {
                        let pastStreakRecord = try viewContext.fetch(streakFetch) as! [Streak]
                        streak.counter = pastStreakRecord.first!.counter + 1
                        do {
                            try viewContext.save()
                            if displayDate(day: streak.date) != displayDate(day: Date()){
                                updateFutureRecords(s: streak, i: true, amount: streak.counter)
                            }
                        } catch {
                            print("error")
                        }
                    } catch {
                        print("error")
                    }
                }else{
                    streak.counter = 1
                    do {
                        try viewContext.save()
                        if displayDate(day: streak.date) != displayDate(day: Date()){
                            updateFutureRecords(s: streak, i: true, amount: streak.counter)
                        }
                    } catch {
                        print("error")
                    }
                }
            }
        }else
        {
            do {
                let streakRecord = try viewContext.fetch(streakFetch) as! [Streak]
                
                let tasksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
                
                let calendar = NSCalendar.current
                // get the start of the day of the selected date
                let startDate = calendar.startOfDay(for: task.date)
                // get the start of the day after the selected date
                var components = DateComponents()
                components.day = 1
                components.second = -1
                let endDate = calendar.date(byAdding: components, to: startDate)!
                // create a predicate to filter between start date and end date
                tasksFetch.predicate = NSPredicate(format: "date >= %@ AND date < %@ AND completed == %@", startDate as NSDate, endDate as NSDate, NSNumber(value: true))
                
                if getRequestCount(request: tasksFetch) == 3{
                    let calendar = NSCalendar.current
                    // get the start of the day of the selected date
                    let startDate = calendar.startOfDay(for: previousDate(day: streakRecord.first!.date))
                    // get the start of the day after the selected date
                    var components = DateComponents()
                    components.day = 1
                    components.second = -1
                    let endDate = calendar.date(byAdding: components, to: startDate)!
                    
                    streakFetch.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
                    
                    
                    if getRequestCount(request: streakFetch) != 0{
                        let pastStreakRecord = try viewContext.fetch(streakFetch) as! [Streak]
                        streakRecord.first!.counter = pastStreakRecord.first!.counter + 1
                        do {
                            try viewContext.save()
                            if displayDate(day: streakRecord.first!.date) != displayDate(day: Date()){
                                updateFutureRecords(s: streakRecord.first!, i: true, amount: streakRecord.first!.counter)
                            }
                        } catch {
                            print("error")
                        }
                    }else{
                        streakRecord.first!.counter = 1
                        do {
                            try viewContext.save()
                            if displayDate(day: streakRecord.first!.date) != displayDate(day: Date()){
                                updateFutureRecords(s: streakRecord.first!, i: true, amount: streakRecord.first!.counter)
                            }
                        } catch {
                            print("error")
                        }
                    }
                }
                
            } catch {
                fatalError("Failed to fetch tasks: \(error)")
            }
            
        }
        
    }
    
    private func updateFutureRecords(s: Streak, i: Bool, amount: Int64){
        let streakFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Streak")
        streakFetch.predicate = NSPredicate(format: "date > %@", s.date as NSDate)
        
        do {
            let records = try viewContext.fetch(streakFetch) as! [Streak]
            for r in records {
                if i{
                    r.counter += amount
                }else
                {
                    r.counter -= amount
                }
            }
            do {
                try viewContext.save()
            } catch {
                print("error")
            }
        } catch {
            print("error")
        }
    }
    
    private func getRequestCount(request: NSFetchRequest<NSFetchRequestResult>) -> Int{
        do{
            return try viewContext.count(for: request)
        } catch {
            return 0
        }
    }
    
    private func previousDate(day: Date) -> Date{
        return day.addingTimeInterval(-86400)
    }
    
    private func uncompleteTodo(t: Task){
        t.completed = false
        do {
            try viewContext.save()
        } catch {
            print("error")
        }
        
        let streakFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Streak")
        let calendar = NSCalendar.current
        // get the start of the day of the selected date
        let startDate = calendar.startOfDay(for: t.date)
        // get the start of the day after the selected date
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = calendar.date(byAdding: components, to: startDate)!
        
        streakFetch.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        streakFetch.fetchLimit = 1
        
        do {
            let StreakRecord = try viewContext.fetch(streakFetch) as! [Streak]
            let temp = StreakRecord.first!.counter
            StreakRecord.first!.counter = 0
            do {
                try viewContext.save()
                if displayDate(day: StreakRecord.first!.date) != displayDate(day: Date()){
                    updateFutureRecords(s: StreakRecord.first!, i: false, amount: temp)
                }
            } catch {
                print("error")
            }
        } catch {
            print("error")
        }
    }
    
    private func displayDate(day: Date) -> String{
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: day)
    }
    
}

