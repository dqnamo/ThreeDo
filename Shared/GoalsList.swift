//
//  SwiftUIView.swift
//  ThreeDo
//
//  Created by John Paul on 10/03/2021.
//
import Foundation
import SwiftUI
import CoreData

struct SwiftUIView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var date: Date
    
    var body: some View {
        ForEach(getTasks()) { task in
            GoalRow(task: task)
        }
        .onDelete(perform: deleteTodo)
    }
    
    private func deleteTodo(at offsets: IndexSet){
        for index in offsets {
            let task = getTasks()[index]
            viewContext.delete(task)
            
            do{
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func getTasks() -> [Task]{
        let tasksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        tasksFetch.predicate = fetchPredicate(filter: date)
         
        do {
            let fetchedTasks = try viewContext.fetch(tasksFetch) as! [Task]
            return fetchedTasks
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
