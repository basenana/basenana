//
//  GroupCreateView.swift
//  basenana
//
//  Created by zww on 2024/6/4.
//

import SwiftUI

struct GroupCreateView: View {
    var parent: GroupModel?
    @Binding var showCreateGroup: Bool
    @Environment(Store.self) private var store: Store
    
    @State private var parentID: Int64 = 0
    @State private var parentName: String = ""
    @State private var groupName: String = ""
    @State private var errorMsg: String = ""
    
    var body: some View{
        Form{
            VStack {
                VStack(alignment: .leading){
                    TextField("Parent", text: $parentName)
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
                        store.dispatch(.createGroup(groupName: groupName, parentId: parentID))
                        showCreateGroup.toggle()
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
        .onAppear{
            if parent != nil{
                parentID = parent!.groupID
                parentName = parent!.groupName
            }else{
                parentID = store.state.fsInfo.rootID
                parentName = "root"
            }
        }
    }
}
