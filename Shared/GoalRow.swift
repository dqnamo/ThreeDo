//
//  GoalRow.swift
//  ThreeDo
//
//  Created by John Paul on 10/03/2021.
//

import Foundation
import CoreData
import SwiftUI
import AVFoundation

struct GoalRow: View {
    @ObservedObject var task: Task
    @State var locked: Bool = false
    @State var past: Bool = false
    @State var editTask: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack {
//        HStack {
//            Text("\(task.name)")
//                .strikethrough(task.completed)
//            if task.completed{
//                Image(systemName: "checkmark.square.fill")
//            }
//        }
//        .padding()
            if !locked{
                HStack{
                    if task.completed{
                        if !past{
                            Text("\(task.name)").foregroundColor(Color.gray)
                        }else{
                            VStack(alignment: .leading){
                                Text("\(task.name)").foregroundColor(Color.gray)
                                Text("\(displayDate(day: task.date))").foregroundColor(Color.gray)
                                    .fontWeight(.regular)
                                    .font(.system(size: 14))
                            }
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.green)
                    }else{
                        if !past{
                            Text("\(task.name)")
                        }else{
                            VStack(alignment: .leading){
                                Text("\(task.name)")
                                Text("\(displayDate(day: task.date))").foregroundColor(Color.gray)
                                    .fontWeight(.regular)
                                    .font(.system(size: 14))
                            }
                        }
                        Spacer()
                        if past{
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                        }
//                            Image(systemName: "square")
//                                .font(.system(size: 20))
                    }
                }
            }else{
                HStack{
                    if task.completed{
                        VStack(alignment: .leading){
                            Text("\(task.name)").foregroundColor(Color.gray)
                                .fontWeight(.bold)
                            Text("\(displayDate(day: task.date))").foregroundColor(Color.gray)
                                .fontWeight(.regular)
                        }
                        
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.green)
                    }else{
                        Text("\(task.name)")
                        Spacer()
                        if past{
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                        }
                        
                    }
                }
            }
        }
        .onTapGesture(count: 1) {
            if locked{ return}
            
            if task.completed{
                uncompleteTodo(t: task)
            }else{
                completeTodo(t: task)
            }
        }
    }
    
    private func completeTodo(t: Task){
        t.completed = true
        do {
            try viewContext.save()
            AudioServicesPlaySystemSound(4095)
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
    
    private func displayDate(day: Date) -> String{
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "E, d MMM y"
        return formatter3.string(from: day)
    }
    
}

