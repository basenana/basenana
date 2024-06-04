//
//  GroupCreateView.swift
//  basenana
//
//  Created by zww on 2024/6/4.
//

import SwiftUI

struct GroupCreateView: View {
    @Binding var showCreateGroup: Bool
    var parent: EntryDetailModel

    @State private var groupName: String = ""
    @State private var errorMsg: String = ""
    
    var body: some View{
        Form{
            VStack {
                VStack(alignment: .leading){
                    TextField("Parent", text: .constant(parent.name))
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
                        Task.detached {
                            entryService.createGroup(groupName: groupName, parentId: parent.id)
                        }
                        showCreateGroup = false
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
