//
//  GroupCreateView.swift
//  basenana
//
//  Created by zww on 2024/6/4.
//

import SwiftUI

struct GroupCreateView: View {
    var parentID: Int64?
    @Binding var showCreateGroup: Bool
    
    @State private var groupName: String = ""
    @State private var errorMsg: String = ""
    
    var parent: EntryDetailModel? {
        get {
            do {
                return try service.getEntry(entryID: self.parentID ?? rootEntryID)
            } catch {
                self.errorMsg = "\(error)"
            }
            return nil
        }
    }
    
    var body: some View{
        Form{
            VStack {
                VStack(alignment: .leading){
                    TextField("Parent", text: .constant(parent?.name ?? "root"))
                        .textFieldStyle(.squareBorder)
                        .disabled(true)
                        .padding(.vertical, 5)
                    
                    TextField("GroupName", text: $groupName)
                        .textFieldStyle(.squareBorder)
                        .padding(.vertical, 5)
                }
                
                HStack {
                    if errorMsg != ""{
                        Text("\(errorMsg)")
                            .foregroundStyle(.red)
                            .padding(.vertical, 5)
                    }
                    Button {
                        do {
                            try service.createGroup(groupName: groupName, parentId: parent!.id)
                            showCreateGroup = false
                        } catch {
                            errorMsg = "\(error)"
                        }
                    } label: {
                        Text("Create")
                            .font(.body)
                            .padding(6)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.vertical, 10)
            }
            .padding(20)
        }
        .formStyle(.grouped)
    }
}
