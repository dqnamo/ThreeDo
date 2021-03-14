//
//  TomorrowTasks.swift
//  ThreeDo
//
//  Created by John Paul on 14/03/2021.
//

import SwiftUI
import CoreData

struct TomorrowTasks: View {
    @State private var name: String = ""
    @State private var name2: String = ""
    @State private var name3: String = ""
    @State private var refreshingID = UUID()
    @State var date: Date
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var errorShowing: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: true)],
        predicate: NSPredicate(format: "date >= %@", Date() as NSDate)
    ) var tasks: FetchedResults<Task>
    
    var body: some View {
            VStack{
                List{
                Section(header: Text(displayDate(day: date))) {
                    ForEach(tasks) { task in
                        if displayDate(day: task.date) == displayDate(day: date){
                            GoalRow(task: task, locked: true)
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
                                        task.date = self.date
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
                }.listStyle(InsetGroupedListStyle())
                .alert(isPresented: $errorShowing, content: {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                })
            }
            .navigationBarTitle("Tomorrow's Goals")

    }
    
    private func displayDate(day: Date) -> String{
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: day)
    }
    
    
    private func deleteTodo(offsets: IndexSet) {
        withAnimation {
            viewContext.perform {
                offsets.map { tasks[$0] }.forEach(viewContext.delete)
                do {
                    try viewContext.save()
                } catch {
                    viewContext.rollback()
                }
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

