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
            viewContext.delete(task)
            
            do{
                try viewContext.save()
                self.refreshingID = UUID()
            } catch {
                print(error)
            }
        }
    }
    
    private func getTasks(day: Date) -> [Task]{
        let tasksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        tasksFetch.predicate = fetchPredicate(filter: day)
         
        do {
            let fetchedTasks = try viewContext.fetch(tasksFetch) as! [Task]
            return fetchedTasks
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    private func completeTodo(t: Task){
        t.completed = true
        do {
            try viewContext.save()
        } catch {
            print("error")
        }
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
