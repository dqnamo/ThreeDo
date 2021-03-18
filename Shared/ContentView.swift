//
//  ContentView.swift
//  Shared
//
//  Created by John Paul on 07/03/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var name: String = ""
    @State private var showSheet: Bool = false
    @State private var date: Date = Date()
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var refreshingID = UUID()
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: true)],
        predicate: NSPredicate(format: "date >= %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate)
    ) var tasks: FetchedResults<Task>

    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    List{
                        Section(header: Text(displayDate(day: date))) {
                            ForEach(tasks) { task in
                                if displayDate(day: task.date) == displayDate(day: date){
                                    GoalRow(task: task, locked: false)
                                        .foregroundColor(.primary)
                                }
                            }
                            .onDelete(perform: deleteTodo)
                            .padding()
                            if getTasks(day: date).count < 3{
                                HStack {
                                    TextField("What is your goal?", text: $name, onCommit: {
                                            let task = Task(context: viewContext)
                                            if self.name != "" {
                                                task.name = self.name
                                                task.date = Date()
                                                task.id = UUID()
                                                self.name = ""
                                                do {
                                                    try viewContext.save()
                                                } catch {
                                                    print("error")
                                                }
                                            }
                                          })
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        Section(header: Text("Tools")) {
                            NavigationLink(destination: PastGoals()) {
                                HStack{
                                    Text("Past Goals")
                                        .foregroundColor(.gray)
                                }.padding()
                            }
                            NavigationLink(destination: TomorrowTasks(date: nextDate(day: Date()))) {
                                HStack{
                                    Text("Plan For Tommorow")
                                        .foregroundColor(.gray)
                                }.padding()
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                
            }
            .navigationBarTitle("Today's Goals")
            .navigationBarItems(leading: Button(action: {showSheet.toggle()}, label: {
                Image(systemName: "questionmark.circle.fill").foregroundColor(.gray)
            }), trailing: StreakCounter())
        }
        .sheet(isPresented: $showSheet, content: {
            Doctrine()
        })
        
    }
    
    private func todayDate() -> String{
        let today = Date()
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: today)
    }
    
    private func nextDate(day: Date) -> Date{
        return day.addingTimeInterval(86400)
    }
    
    private func previousDate(day: Date) -> Date{
        return day.addingTimeInterval(-86400)
    }
    
    private func displayDate(day: Date) -> String{
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: day)
    }
    
    
    private func deleteTodo(at offsets: IndexSet){
        for index in offsets {
            let task = tasks[index]
            let tempDate = task.date
            viewContext.delete(task)
            
            do{
                try viewContext.save()
                self.refreshingID = UUID()
                
                let streakFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Streak")
                let calendar = NSCalendar.current
                // get the start of the day of the selected date
                let startDate = calendar.startOfDay(for: tempDate)
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
            } catch {
                print(error)
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
                        } catch {
                            print("error")
                        }
                    }else{
                        streakRecord.first!.counter = 1
                        do {
                            try viewContext.save()
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
    
    private func getRequestCount(request: NSFetchRequest<NSFetchRequestResult>) -> Int{
        do{
            return try viewContext.count(for: request)
        } catch {
            return 0
        }
    }
    
    private func getTasks(day: Date) -> [Task]{
        let tasksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        tasksFetch.predicate = fetchPredicate(filter: day)
         
        do {
            let fetchedTasks = try viewContext.fetch(tasksFetch) as! [Task]
            return fetchedTasks
        } catch {
            fatalError("Failed to fetch tasks: \(error)")
        }
    }
    
    private func completeTodo(t: Task){
        t.completed = true
        do {
            try viewContext.save()
        } catch {
            print("error")
        }
        createStreakRecord(task: t)
    }
    
    private func uncompleteTodo(t: Task){
        t.completed = false
        do {
            try viewContext.save()
        } catch {
            print("error")
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
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        
        return predicate
    }
    
    private func getRequest(day: Date) -> NSFetchRequest<NSFetchRequestResult>{
        let test = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        test.predicate = fetchPredicate(filter: day)
        return test
    }
}
