//
//  GroupMenuView.swift
//  basenana
//
//  Created by Hypo on 2024/6/23.
//

import SwiftUI
import Foundation


struct GroupMenuView: View {
    var entry: EntryInfoModel?
    var group: GroupModel?

    var body: some View {
        Section{
            Button("New Group", action: {})
        }
        
        Section{
            Button("Open", action: {})
        }
        
        // web page
        Section{
            Button("Launch URL", action: {})
            Button("Copy URL", action: {})
        }
        
        Section{
            Button("Rename", action: {})
            Button("Delete", action: {})
        }
        
        Section{
            Menu("Move To") {
                Button("Group 1", action: { print("Option 1 selected") })
                Button("Group 2", action: { print("Option 2 selected") })
            }
            Menu("Replicate To") {
                Button("Group 1", action: { print("Option 1 selected") })
                Button("Group 2", action: { print("Option 2 selected") })
            }
        }
        
        Section{
            Menu("Mark") {
                Button("As Marked", action: { print("Option 1 selected") })
                Button("As Unread", action: { print("Option 2 selected") })
            }
        }
    }
}


#Preview {
    GroupMenuView(entry: nil, group: nil)
}
