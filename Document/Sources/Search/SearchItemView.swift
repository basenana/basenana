//
//  SwiftUIView.swift
//  Document
//
//  Created by Weiwei on 2025/4/3.
//

import os
import SwiftUI
import Entities

struct SearchItemView: View {
    @State var doc: DocumentSearchItem
    @State var searchModel: SearchViewModel
    
    @State var properties: [EntryProperty]
    @State var parent: EntryInfo
    @Binding var isHovering: Bool
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: SearchItemView.self)
        )
    
    init(doc: DocumentSearchItem, searchModel: SearchViewModel, isHovering: Binding<Bool>) {
        self.doc = doc
        self.searchModel = searchModel
        self.properties = doc.properties
        self.parent = doc.parent
        self._isHovering = isHovering
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top){
                Image(systemName: "text.document")
                    .padding(.top, 1)
                
                VStack(alignment: .leading) {
                            
                    HStack(){
                        HighlightedTitle(title: self.docTitle, key: self.searchModel.search, isHovering: self.isHovering)
                        Spacer()
                        Text(self.docTime)
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                    Text(self.footnote)
                        .foregroundColor(Color.gray)
                        .font(.footnote)

                    HStack{
                        if searchModel.showImagePreview {
                            SearchItemBannerView(bannerURL: doc.headerImage)
                                .frame(width: 50, height: 40)
                        }
                        HighlightedText(content: self.searchContent)
                            .font(.body)
                    }
                    .frame(height: 50)
                }
                .padding(.vertical, 3)
            }
        }
        .contextMenu {
            SearchMenuView(document: $doc, viewModel: searchModel)
        }
        .toolbar(removing: .sidebarToggle)
    }
    
    var footnote: String {
        var groupName = "\(self.groupName.prefix(25))"
        if groupName.count == 0 {
            return self.docURL
        }
        if self.docURL.count == 0 {
            return groupName
        }
        return "\(groupName) / \(self.docURL)"
    }
    
    var docTitle: String {
        return properties.filter({ $0.key == Property.WebPageTitle}).first?.value ?? doc.info.name
    }
    
    var searchContent: String {
        var searchContent: String = self.doc.info.subContent
        if self.doc.info.searchContent.count > 0 {
            searchContent = self.doc.info.searchContent[0]
        }
        self.doc.info.searchContent.forEach { sc in
            if searchContent.count < 400 {
                searchContent += sc
            }
        }
        return searchContent
    }
    
    var docTime: String {
        var datetime = doc.info.createdAt
        
        let updateAt = properties.filter({ $0.key == Property.WebPageUpdateAt}).first?.value ?? ""
        guard updateAt != "" else {
            return dateFormatter.string(from: datetime)
        }
        
        
        if let paresedDate = rfc3339Formatter.date(from: updateAt) {
            datetime = paresedDate
        }else {
            Self.logger.error("parse web page update at failed, got \(updateAt)")
        }
        
        return dateFormatter.string(from: datetime)
    }

    var docURL: String {
        if let urlStr = properties.filter({ ($0.key == Property.WebPageURL || $0.key == Property.WebSiteURL) && !$0.value.isEmpty }).first?.value{
            return URL(string: urlStr)?.host() ?? ""
        }
        return ""
    }
    
    var groupName: String {
        return properties.filter({ $0.key == Property.WebSiteName}).first?.value ?? entryTitleName(en: parent)
    }
    
    let rfc3339Formatter = RFC3339Formatter()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()
}

struct HighlightedTitle: View {
    let title: String
    let key: String
    let isHovering: Bool
    
    var body: some View {
        if isHovering {
            return Text(title).font(.headline)
        }
        var result: Text = Text("")
        var currentIndex = title.startIndex

        while let range = title.range(of: key, options: .caseInsensitive, range: currentIndex..<title.endIndex) {
            // Add the text before the match
            let beforeMatch = title[currentIndex..<range.lowerBound]
            result = result + Text(beforeMatch).font(.body).foregroundColor(.gray)
            
            // Add the matched substring in bold
            let matchedSubstring = title[range]
            result = result + Text(matchedSubstring).font(.headline)
            
            // Move the current index to after the matched substring
            currentIndex = range.upperBound
        }
        
        // Add any remaining text after the last match
        let remainingText = title[currentIndex..<title.endIndex]
        result = result + Text(remainingText).font(.body).foregroundColor(.gray)

        return result
    }
}


struct HighlightedText: View {
    let content: String

    var body: some View {
        let components = parseHTML(content)
        return components.reduce(Text("")) { (result, component) in
            switch component {
            case .normal(let text):
                return result + Text(text).font(.body).foregroundColor(.gray)
            case .bold(let text):
                return result + Text(text).font(.headline)
            }
        }
    }

    // A simple HTML parser to detect <b> tags
    func parseHTML(_ html: String) -> [Component] {
        var components: [Component] = []
        var currentIndex = html.startIndex

        while let startRange = html.range(of: "<b>", range: currentIndex..<html.endIndex),
              let endRange = html.range(of: "</b>", range: startRange.upperBound..<html.endIndex) {
            // Add normal text before the <b> tag
            if currentIndex < startRange.lowerBound {
                let normalText = String(html[currentIndex..<startRange.lowerBound])
                components.append(.normal(normalText))
            }

            // Add bold text inside <b> tags
            let boldText = String(html[startRange.upperBound..<endRange.lowerBound])
            components.append(.bold(boldText))

            // Update current index
            currentIndex = endRange.upperBound
        }

        // Add remaining normal text
        if currentIndex < html.endIndex {
            let normalText = String(html[currentIndex..<html.endIndex])
            components.append(.normal(normalText))
        }

        return components
    }

    enum Component {
        case normal(String)
        case bold(String)
    }
}


struct SearchItemBannerView: View{
    var bannerURL: String
    
    var body: some View {
        if let safeUrl = URL(string: bannerURL) {
            GeometryReader { geometry in
                AsyncImage(url: safeUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .padding(.vertical, 5)
                        .clipped()
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding(50)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundStyle(.gray)
                }
            }
            .aspectRatio(3/2, contentMode: .fit)
        }
    }
}


#if DEBUG

import AppState
import DomainTestHelpers

struct SearchViewItemPreview: View {
    @State private var doc: DocumentInfo? = nil
    @State private var uc = MockDocumentUseCase()
    
    var body: some View {
        VStack{
            SearchView(search: "hello", viewModel: SearchViewModel(store: StateStore.shared, usecase: uc) )
        }
        .task {
            do {
                let docs = try await uc.searchDocuments(search: "hello", page: 1, pageSize: 1).first!
            } catch {
                print("Failed to load entry details: \(error)")
            }
        }
    }
}

#Preview{
    SearchViewPreview()
}

#endif

