//
//  GroupCreateView.swift
//  basenana
//
//  Created by zww on 2024/6/4.
//

import SwiftUI
import FeedKit

enum GroupType: Identifiable {
    case standard
    case feed
    case dynamic
    
    var id: String {
        get {
            switch self {
            case .standard:
                return "group_standard"
            case .feed:
                return "group_feed"
            case .dynamic:
                return "group_dynamic"
            }
        }
    }
}

//struct GroupCreateView: View {
//    var parent: GroupModel?
//    var groupType: GroupType = GroupType.standard
//    
//    @Environment(Store.self) private var store: Store
//    
//    @State private var parentID: Int64 = 0
//    @State private var parentName: String = ""
//    @State private var groupName: String = ""
//    @State private var siteName: String = ""
//    @State private var siteURL: String = ""
//    @State private var rssFeed: String = ""
//    @State private var errorMsg: String = ""
//    
//    var body: some View{
//        Form{
//            TextField("Parent", text: $parentName)
//                .textFieldStyle(.roundedBorder)
//                .disabled(true)
//                .padding(.vertical, 5)
//            
//            if groupType == GroupType.feed {
//                TextField("Feed", text: $rssFeed, onCommit: parseRssTitle )
//                    .textFieldStyle(.roundedBorder)
//                    .padding(.vertical, 5)
//            }
//            
//            TextField("GroupName", text: $groupName)
//                .textFieldStyle(.roundedBorder)
//                .padding(.vertical, 5)
//            
//            
//            HStack {
//                if errorMsg != ""{
//                    Text("\(errorMsg)")
//                        .foregroundStyle(.red)
//                        .padding(.vertical, 5)
//                        .padding(.trailing, 20)
//                }
//                Button {
//                    store.dispatch(.createGroup(groupName: groupName, parentId: parentID, opt: buildOption()))
//                } label: {
//                    Text("Create")
//                        .font(.body)
//                        .padding(6)
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                }
//                .buttonStyle(PlainButtonStyle())
//            }
//            .frame(maxWidth: .infinity, alignment: .trailing)
//            .padding(.top, 10)
//        }
//        .padding(50)
//        .frame(minWidth: 500)
//        .onAppear{
//            if parent != nil{
//                parentID = parent!.groupID
//                parentName = parent!.groupName
//            }else{
//                parentID = store.state.fsInfo.rootID
//                parentName = "root"
//            }
//        }
//    }
//    
//    func buildOption() -> GroupCreateOptionModel {
//        var opt = GroupCreateOptionModel()
//        opt.groupType = groupType
//        opt.feed = rssFeed
//        opt.siteName = siteName
//        opt.siteURL = siteURL
//        return opt
//    }
//    
//    func parseRssTitle() {
//        if let validUrl = URL(string: rssFeed){
//            let parser = FeedParser(URL: validUrl)
//            parser.parseAsync(result: { result in
//                switch result {
//                case .success(let feed):
//                    siteName = feed.rssFeed?.title ?? feed.atomFeed?.title ?? feed.jsonFeed?.title ?? ""
//                    siteURL = feed.rssFeed?.link ?? feed.atomFeed?.links?.first?.attributes?.href ?? feed.jsonFeed?.homePageURL ?? ""
//                    groupName = sanitizeFileName(siteName)
//                case .failure(let err):
//                    errorMsg = "Not a valid feed URL \(err.errorDescription ?? "")"
//                }
//            })
//        }
//    }
//}
