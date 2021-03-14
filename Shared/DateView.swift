//
//  DateView.swift
//  ThreeDo
//
//  Created by John Paul on 11/03/2021.
//

import SwiftUI
import Foundation
import CoreData

struct DateView: View {
    @State private var name: String = ""
    @State var forceUpdate: Bool = false
    @State private var errorShowing: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showingAddTodoView: Bool = false
    var date: Date = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var refreshingID = UUID()
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: []
    ) var tasks: FetchedResults<Task>
    
    @State private var selection = 2
    
//    init(predicate: NSPredicate) {
//        _tasks = FetchRequest(entity: Task.entity(), sortDescriptors: [], predicate: predicate)
//    }
    
    var body: some View {
//        NavigationView{
            VStack(alignment: .leading){
                Spacer(minLength: 30)
                VStack(alignment: .leading){
                    Menu {
                        Link("📖 The ThreeDo Doctrine", destination: URL(string: "https://www.hackingwithswift.com/quick-start/swiftui")!)
                        Link("💎 About Us", destination: URL(string: "https://www.hackingwithswift.com/quick-start/swiftui")!)
                    } label: {
                        Image(systemName: "book")
                        Text("Help")
                    }
                    Text(self.dayHeading(day: date))
                        .fontWeight(.bold)
                        .font(.system(size: 30))
                    Text(self.displayDate(day: date))
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.top, 5)
                        .padding(.bottom, 10)
//                    DatePicker("", selection: $date, displayedComponents: .date)
//                        .datePickerStyle(CompactDatePickerStyle())
//                        .onChange(of: date, perform: { (value) in
//                            self.showingAddTodoView.toggle()
//                            print("hello")
//                                                })
//                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                        .padding(.bottom, 10)

//                    Text(self.todayDate())
//                        .font(.system(size: 15))
//                        .foregroundColor(Color(UIColor.secondaryLabel))
//                        .padding(.top, 5)
//                        .padding(.bottom, 10)
                }
                .padding(.leading, 20)
//                VStack(alignment: .leading){
//                    Text("🎯 Today's Goals")
//                        .fontWeight(.bold)
//                        .font(.system(size: 30))
//                    DatePicker("", selection: $date, displayedComponents: .date)
//                        .datePickerStyle(CompactDatePickerStyle())
//                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                        .padding(.bottom, 10)
//
////                    Text(self.todayDate())
////                        .font(.system(size: 15))
////                        .foregroundColor(Color(UIColor.secondaryLabel))
////                        .padding(.top, 5)
////                        .padding(.bottom, 10)
//                }
//                .padding(.leading, 20)
//                VStack(alignment: .trailing){
//                    Image(systemName: "checkmark.square.fill")
//                }
                VStack(alignment: .leading){
                    List{
                        Spacer(minLength: 10)
//                        GoalsList(date: date)
                        ForEach(tasks) { task in
                            GoalRow(task: task)
                        }
                        .onDelete(perform: deleteTodo)
                        .id(refreshingID)
                        if tasks.count < 3{
                            HStack {
                                Button(action: {
                                    self.showingAddTodoView.toggle()
                                    print("wow")
                                }, label: {
                                    Text("Add A Goal")
                                        .foregroundColor(.white)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                })
                            }
                            .padding()
                            .listRowBackground(Color.blue)
                        }
                    }
                    Form{
                        TextField("Describe your goal", text: $name)
                            .padding()
                        Button(action: {
                            let task = Task(context: viewContext)
                            if self.name != "" {
                                task.name = self.name
                                task.date = self.date
                                task.id = UUID()
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
                            Text("Create Goal")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .background(Color("ColorBase"))
                                .foregroundColor(.white)
                        })
                        .padding()
                        .listRowBackground(Color.blue)
                    }
//                    .onAppear {
//                        UITableView.appearance().isScrollEnabled = false
//                    }
//                    .listStyle(InsetGroupedListStyle())
                }
                .sheet(isPresented: $showingAddTodoView, content: {
                                AddTodoView(date: date)
                            })
                
//            }
//            .navigationBarTitle("🎯 Today's Goals")
//            .navigationBarHidden(true)
//            .sheet(isPresented: $showingAddTodoView, content: {
//                AddTodoView(date: date)
//            })

        }.id(refreshingID)
    }
    
    private func dayHeading(day: Date) -> String{
        if displayDate(day: day) == displayDate(day: Date()){
            return "Today's Goals"
        }
        if displayDate(day: day) == displayDate(day: Date().addingTimeInterval(86400)){
            return "Tommorow's Goals"
        }
        if displayDate(day: day) == displayDate(day: Date().addingTimeInterval(-86400)){
            return "Yesterday's Goals"
        }
        return "ThreeToDo"
    }

    
    private func todayDate() -> String{
        let today = Date()
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: today)
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
            self.refreshingID = UUID()
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
