//
//  GroupCreateView.swift
//  basenana
//
//  Created by zww on 2024/6/4.
//

import SwiftUI
import FeedKit
import Domain


struct GroupCreateView: View {
    @State private var parent: EntryGroup? = nil
    @State private var parentUri: String
    @State var groupType: GroupType
    @State private var viewModel: CreateDeleteViewModel

    @Binding private var showCreateGroup: Bool

    init(parentUri: String, groupType: GroupType, viewModel: CreateDeleteViewModel, showCreateGroup: Binding<Bool>) {
        self.parentUri = parentUri
        self.groupType = groupType
        self.viewModel = viewModel
        self._showCreateGroup = showCreateGroup
    }

    // Common
    @State private var parentName: String = ""
    @State private var groupName: String = ""

    // RSS EntryGroup
    @State private var siteName: String = ""
    @State private var siteURL: String = ""
    @State private var rssFeed: String = ""
    @State private var errorMsg: String = ""

    var body: some View{
        Form{
            TextField("Parent", text: $parentName)
                .textFieldStyle(.roundedBorder)
                .disabled(true)
                .padding(.vertical, 5)

            if groupType == GroupType.feed {
                TextField("Feed", text: $rssFeed, onCommit: parseRssTitle )
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 5)
            }

            TextField("GroupName", text: $groupName)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 5)


            HStack {
                if errorMsg != ""{
                    Text("\(errorMsg)")
                        .foregroundStyle(.red)
                        .padding(.vertical, 5)
                        .padding(.trailing, 20)
                }
                Button {
                    Task {
                        await viewModel.createGroup(parentUri: parentUri, option: buildOption())
                        showCreateGroup.toggle()
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
            .padding(.top, 10)
        }
        .task{
            if let p = await viewModel.describeEntry(uri: parentUri){
                parent = p.toGroup()
                parentName = parent?.groupName ?? "Unknown"
            }
        }
        .padding(50)
        .frame(minWidth: 500)
    }

    func buildOption() -> EntryCreate {
        var opt = EntryCreate(parentUri: parentUri, name: groupName, kind: "group")
        opt.RSS = RSSConfig(feed: rssFeed, siteName: siteName, siteURL: siteURL, fileType: .Webarchive)
        return opt
    }

    func parseRssTitle() {
        if let validUrl = URL(string: rssFeed){
            let parser = FeedParser(URL: validUrl)
            parser.parseAsync(result: { result in
                switch result {
                case .success(let feed):
                    siteName = feed.rssFeed?.title ?? feed.atomFeed?.title ?? feed.jsonFeed?.title ?? ""
                    siteURL = feed.rssFeed?.link ?? feed.atomFeed?.links?.first?.attributes?.href ?? feed.jsonFeed?.homePageURL ?? ""
                    groupName = sanitizeFileName(siteName)
                case .failure(let err):
                    errorMsg = "Not a valid feed URL \(err.errorDescription ?? "")"
                }
            })
        }
    }
}
