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
            VStack{
                Spacer(minLength: 30)
                VStack{
                    Text("🎯 Today's Goals")
                        .fontWeight(.bold)
                        .font(.system(size: 30))
                    Text(self.todayDate())
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.top, 5)
                        .padding(.bottom, 10)
                }
                VStack{
                    List{
                        ForEach(tasks) { task in
                            Button(action: {
                                if task.completed{
                                    uncompleteTodo(t: task)
                                }else{
                                    completeTodo(t: task)
                                }
                            }){
                                HStack {
                                    Text("\(task.name)")
                                        .strikethrough(task.completed)
                                    if task.completed{
                                        Image(systemName: "checkmark.square.fill")
                                    }
                                }
                                .padding()
                            }.buttonStyle(PlainButtonStyle())
                        }
                        .onDelete(perform: deleteTodo)
                        if tasks.count < 3{
                            HStack {
                                Button(action: {
                                    self.showingAddTodoView.toggle()
                                }, label: {
                                    Text("🚀 Add a goal")
                                        .foregroundColor(.white)
                                })
                            }
                            .padding()
                            .listRowBackground(Color.blue)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTodoView, content: {
                AddTodoView()
            })

        }
    }
    
    private func todayDate() -> String{
        let today = Date()
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: today)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
