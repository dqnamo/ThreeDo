//
//  GoalRow.swift
//  ThreeDo
//
//  Created by John Paul on 10/03/2021.
//

import Foundation
import CoreData
import SwiftUI

struct GoalRow: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
//        HStack {
//            Text("\(task.name)")
//                .strikethrough(task.completed)
//            if task.completed{
//                Image(systemName: "checkmark.square.fill")
//            }
//        }
//        .padding()
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

