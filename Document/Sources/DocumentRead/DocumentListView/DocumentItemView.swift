//
//  DocumentItemView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI
import Entities


@available(macOS 14.0, *)
struct DocumentItemView: View {
    private var section: String
    @State var doc: DocumentItem
    @State var viewModel: DocumentListViewModel
    
    @State var entry: EntryDetail? = nil
    @State var parentEntry: EntryDetail? = nil
    @State var properties: [EntryProperty] = []
    
    init(section: String, doc: DocumentItem, viewModel: DocumentListViewModel ) {
        self.section = section
        self.doc = doc
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(docTitle)
                .font(.title2)
                .multilineTextAlignment(.leading)
                .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
            
            Spacer(minLength: 10)
            
            HStack(alignment: .top) {
                Text("\(groupName.prefix(25))")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(Color.gray)
                Spacer()
                
                Text(docTime)
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(Color.gray)
            }
            
            
            DocumentBannerView(bannerURL: "")
                .padding(.vertical, 5)
            
            Text(doc.info.subContent.trimmingCharacters(in: .whitespaces))
                .font(.body)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.leading)
            
            Text(docURL)
                .font(.caption2)
                .fontWeight(.light)
                .foregroundColor(Color.gray)

        }
        .padding(30)
        .contextMenu {
            if let en = entry {
                DocumentMenuView(section: section, document: $doc, entry: en, viewModel: viewModel)
            }
        }
        .task {
            if let getEntry = viewModel.getDocumentEntry(entry: doc.info.oid){
                entry = getEntry
                properties = getEntry.properties
                parentEntry = viewModel.getDocumentEntry(entry: getEntry.parent)
            }
        }
    }
    
    var docTitle: String {
        return properties.filter({ $0.key == Property.WebPageTitle}).first?.value ?? doc.info.name
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
            print("parse web page update at failed, got \(updateAt)")
        }
        
        return dateFormatter.string(from: datetime)
    }
    
    var docURL: String {
        if let urlStr = properties.filter({ ($0.key == Property.WebPageURL || $0.key == Property.WebSiteURL) && !$0.value.isEmpty }).first?.value{
            return URL(string: urlStr)?.host() ?? parentEntry?.name ?? ""
        }
        return parentEntry?.name ?? ""
    }
    
    var groupName: String {
        return properties.filter({ $0.key == Property.WebSiteName}).first?.value ?? ""
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


struct DocumentBannerView: View{
    var bannerURL: String
    
    var body: some View {
        Rectangle()
            .fill(Color.gray)
            .frame(alignment: .center)
        //                .resizable()
            .scaledToFit()
    }
}


#if DEBUG

import AppState
import DomainTestHelpers

#Preview {
    let uc = MockDocumentUseCase()
    let doc = try! uc.listUnreadDocuments(page: 1, pageSize: 1).first!
    
    DocumentItemView(section: "", doc: DocumentItem(info: doc), viewModel: DocumentListViewModel(prespective: .unread, store: StateStore.empty, usecase: uc))
}

#endif
