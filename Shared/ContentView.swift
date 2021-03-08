//
//  ContentView.swift
//  Shared
//
//  Created by John Paul on 07/03/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showingAddTodoView: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Task.entity(), sortDescriptors: [])

    var tasks: FetchedResults<Task>

    var body: some View {
        NavigationView{
            List{
                ForEach(tasks) { task in
                    HStack {
                        Text("\(task.name)")
                    }
                    .padding()
                }
                .onDelete(perform: deleteTodo)
            }
            .listStyle(InsetGroupedListStyle())
//            List(tasks) { task in
//                Text("\(task.name)")
//            }
                .navigationBarTitle("Today's Tasks")
                .navigationBarItems(trailing:
                    Button(action: {
                        self.showingAddTodoView.toggle()
                    }, label: {
                        Image(systemName: "plus")
                    }))
            .sheet(isPresented: $showingAddTodoView, content: {
                AddTodoView()
            })
        }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
