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
                Text("Have you ever had a packed list of tasks in your todo list and you are roaring to get the day started to have the most productive day ever but by the end of the day you are still nowhere near finished and you are left feeling guilty and unaccomplished?")
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                Text("We have all been here and the honest truth is most of us underestimate what we can do in one year but overestimate what we can do in one day.")
                    .padding(.bottom, 20)
                Text("What does ThreeDo have to do with this? ThreeDo is not just another todo app, but a new way of thinking about your daily tasks.").foregroundColor(.gray)
                Text(" So, how do you do todo lists the ThreeDo way?").bold().foregroundColor(.gray).padding(.bottom, 20)
                
                ZStack{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.black)
                                    .frame(height: 50)
                    Text("Pick 3 Core Goals and COMMIT 🚀").bold()
                }.padding(.bottom, 20)
                
                Text("You might say but I only get three things done in a day?! But three core goals done a day is 90 core goals a month and 1092 core goals a year! So declutter your day and be more productive in the process!").foregroundColor(.gray)
                
                Spacer()
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
