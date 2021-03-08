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
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var errorShowing: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView{
            VStack{
                Form{
                    TextField("New goal", text: $name)
                    Button(action: {
                        let task = Task(context: viewContext)
                        if self.name != "" {
                            task.name = self.name
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
                            return
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Save goal")
                            .background(Color("ColorBase"))
                    })
                }
            }
                .navigationBarTitle("Add Todo")
                .navigationBarItems(trailing:
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    }))
            .alert(isPresented: $errorShowing, content: {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
