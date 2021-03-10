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
    @State private var errorShowing: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showingAddTodoView: Bool = false
    @State private var date: Date = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var refreshingID = UUID()
//    @FetchRequest(entity: Task.entity(), sortDescriptors: [])

//    var tasks: FetchedResults<Task>
    var body: some View {
        NavigationView{
            VStack{
                Spacer(minLength: 30)
                VStack{
                    Text("🎯 Today's Goals")
                        .fontWeight(.bold)
                        .font(.system(size: 30))
                    DatePicker("", selection: $date, displayedComponents: .date)
                                            .datePickerStyle(CompactDatePickerStyle())
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding(.bottom, 10)
//                    Text(self.todayDate())
//                        .font(.system(size: 15))
//                        .foregroundColor(Color(UIColor.secondaryLabel))
//                        .padding(.top, 5)
//                        .padding(.bottom, 10)
                }
                VStack{
                    List{
//                        GoalsList(date: date)
                        ForEach(getTasks()) { task in
                            GoalRow(task: task)
                        }
                        .onDelete(perform: deleteTodo)
                        .id(refreshingID)
                        if getTasks().count < 3{
                            HStack {
                                Button(action: {
                                    self.showingAddTodoView.toggle()
                                }, label: {
                                    Text("Add a goal")
                                        .foregroundColor(.white)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                })
                            }
                            .padding()
                            .listRowBackground(Color(.sRGB, red: 0.2, green: 0.9, blue: 0.88))
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTodoView, content: {
                AddTodoView(date: date)
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
            let task = getTasks()[index]
            viewContext.delete(task)
            
            do{
                try viewContext.save()
                self.refreshingID = UUID()
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
