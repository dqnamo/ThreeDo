//
//  PastTasks.swift
//  ThreeDo
//
//  Created by John Paul on 14/03/2021.
//

import SwiftUI
import CoreData

struct PastGoals: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: false)],
        predicate: NSPredicate(format: "date < %@", Date() as NSDate)
    ) var tasks: FetchedResults<Task>
    
    var body: some View {
            VStack{
                List{
                    Section(header: Text("View & Complete")) {
                        ForEach(tasks) { task in
                            if displayDate(day: Date()) != displayDate(day: task.date){
                                GoalRow(task: task, locked: false, past: true )
                                    .foregroundColor(.primary)
                                    .padding()
                            }
                        }
                        
                        if allCount() == 0{
                            HStack{
                                Text("Oh, Looks like you haven't completed any goals yet.").foregroundColor(.gray)
                            }.padding(40)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("Past Goals")
            .navigationBarItems(trailing: Text("\(completedCount()) ✅"))
        }
    
    private func displayDate(day: Date) -> String{
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: day)
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
    
    private func completedCount() -> Int{
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetch.predicate = NSPredicate(format: "date < %@ AND completed == %@", Date() as NSDate, NSNumber(value: true))
        do{
            return try viewContext.count(for: fetch)
        }catch{
            print(error)
        }
        
        return 0
    }
    
    private func allCount() -> Int{
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetch.predicate = NSPredicate(format: "date < %@", Date() as NSDate)
        do{
            return try viewContext.count(for: fetch)
        }catch{
            print(error)
        }
        
        return 0
    }

}
