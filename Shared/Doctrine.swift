//
//  Doctrine.swift
//  ThreeDo
//
//  Created by John Paul on 14/03/2021.
//

import SwiftUI

struct Doctrine: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                Text("Have you ever had packed list of tasks in your todo list ready and you are roaring to get the day started to have the most productive day ever but by the end of the day you still nowhere near finished and you are left feeling guilty and unaccomplished?")
                
                Text("We have all been here and the honest truth is most of us underestimate what we can do in one year but overestimate what we can do in one day.")
                Text("This is where Threedo comes in. ThreeDo is not just another todo app, but a philosophy and a new way of thinking about your tasks.")
                Text("You pick three core goals and COMMIT.")
                
                
            }.padding()
            .navigationBarTitle("ThreeDo Doctrine")
            .navigationBarItems(trailing:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                }))
        }
    }
}
