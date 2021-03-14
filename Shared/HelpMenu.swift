//
//  HelpMenu.swift
//  ThreeDo
//
//  Created by John Paul on 12/03/2021.
//

import SwiftUI

struct HelpMenu: View {
    var body: some View {
        Menu {
            Link("📖 The ThreeDo Doctrine", destination: URL(string: "https://www.hackingwithswift.com/quick-start/swiftui")!)
            Link("💎 About Us", destination: URL(string: "https://www.hackingwithswift.com/quick-start/swiftui")!)
        } label: {
            Image(systemName: "questionmark.circle.fill")
        }
    }
}
