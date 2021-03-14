//
//  ContentView.swift
//  Shared
//
//  Created by John Paul on 07/03/2021.
//

import SwiftUI
import CoreData

enum ActiveSheet: Identifiable {
    case pastGoals, tomorrowGoals
    var id: Int {
        hashValue
    }
}

struct ContentView: View {
    @State var activeSheet: ActiveSheet?
    @State var isEditMode: EditMode = .inactive
    @State private var name: String = ""
    @State private var revealDetails = false
    @State private var revealDetails1 = false
    @State private var errorShowing: Bool = false
    @State private var showSheet: Bool = false
    @State private var togglePastTasks: Bool = false
    @State private var toggleTommorow: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showingAddTodoView: Bool = false
    @State private var todotoday: Bool = false
    @State private var showingAddTodoView2: Bool = false
    @State private var addOnDate: Date = Date()
    @State private var date: Date = Date()
    @State private var viewDay: String = "Today"
    @Environment(\.managedObjectContext) private var viewContext
    @State private var refreshingID = UUID()
    
    @State private var selection = 2
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: true)],
        predicate: NSPredicate(format: "date >= %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate)
    ) var tasks: FetchedResults<Task>
//    @FetchRequest(entity: Task.entity(), sortDescriptors: [])
    
//    var tasks: FetchedResults<Task>
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
                                    TextField("What is your goal?", text: $name)
                                    Spacer()
                                    Button(action: {
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
                                        } else{
                                            self.errorShowing = true
                                            self.errorTitle = "Oops."
                                            self.errorMessage = "Looks like you forgot describe your goal!"
                                            viewContext.delete(task)
                                            return
                                        }
                                    }, label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 18))
                                    })
                                    
                                }
                                .padding()
                            }
                        }
                        Section(header: Text("Tools")) {
                            NavigationLink(destination: PastTasks()) {
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
            .navigationBarTitle("\(viewDay)'s Goals")
            .navigationBarItems(leading: Button(action: {showSheet.toggle()}, label: {
                Image(systemName: "questionmark.circle.fill")
            }), trailing: StreakCounter())
        }
//        .sheet(item: $activeSheet){ item in
//            switch item {
//            case .pastGoals:
//                PastTasks()
//            case .tomorrowGoals:
//                TomorrowTasks(date: nextDate(day: Date()))
//            }
//        }
        .sheet(isPresented: $showSheet, content: {
            Doctrine()
        })
        
    }
    
//    private func pageHeading() -> Text{
//        
//    }
    
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
