//
//  AddTodoView.swift
//  ThreeDo
//
//  Created by John Paul on 08/03/2021.
//
import Foundation
import SwiftUI
import CoreData

struct AddTodoView: View {
    @State private var name: String = ""
    @State var date: Date
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var errorShowing: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                Form{
                    TextField("What is your goal?", text: $name)
                        .padding()
                    Button(action: {
                        let task = Task(context: viewContext)
                        if self.name != "" {
                            task.name = self.name
                            task.date = self.date
                            task.id = UUID()
                            do {
                                try viewContext.save()
                                presentationMode.wrappedValue.dismiss()
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
            }
            .navigationBarTitle("Add Goal")
            .navigationBarItems(trailing:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                }))
        }
        .alert(isPresented: $errorShowing, content: {
            Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        })
    }
    
    private func displayDate(day: Date) -> String{
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: day)
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
