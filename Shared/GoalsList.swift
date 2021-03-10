//
//  SwiftUIView.swift
//  ThreeDo
//
//  Created by John Paul on 10/03/2021.
//
import Foundation
import SwiftUI
import CoreData

struct GoalsList: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Task.entity(), sortDescriptors: [])
    var tasks: FetchedResults<Task>
    
    init(date: Date) {
        _tasks = FetchRequest(sortDescriptors: [], predicate: fetchPredicate(filter: date))
    }
    
    
    var body: some View {
        ForEach(tasks) { task in
            GoalRow(task: task)
        }
        .onDelete(perform: deleteTodo)
    }
    
    private func deleteTodo(at offsets: IndexSet){
        for index in offsets {
            let task = tasks[index]
            viewContext.delete(task)
            
            do{
                try viewContext.save()
            } catch {
                print(error)
            }
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
}
