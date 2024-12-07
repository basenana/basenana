//
//  MasonryItemView.swift
//  Document
//
//  Created by Hypo on 2024/12/4.
//

import SwiftUI
import Entities
import Styleguide


struct MasonryItemView: View {
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
            Spacer(minLength: 20)

            Text(docTitle)
                .font(.title2)
                .multilineTextAlignment(.leading)
                .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
            
            Spacer(minLength: 10)
            
            
//            MasonryItemBannerView(bannerURL: "")
//                .padding(.vertical, 5)
            
            Text("\(doc.info.subContent)... ")
                .font(.body)
                .lineSpacing(2)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 10)
            Text(docURL)
                .font(.caption2)
                .fontWeight(.light)
                .foregroundColor(Color.gray)

        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .background(Color.background)
        .cornerRadius(5)
        .contextMenu {
            if let en = entry {
                DocumentMenuView(section: section, document: $doc, entry: en, viewModel: viewModel)
            }
        }
        .task {
            if let getEntry = await viewModel.getDocumentEntry(entry: doc.info.oid) {
                entry = getEntry
                properties = getEntry.properties
                parentEntry = await viewModel.getDocumentEntry(entry: getEntry.parent)
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


struct MasonryItemBannerView: View{
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

struct MasonryItemViewPreview: View {
    @State private var doc: DocumentInfo? = nil
    @State private var uc = MockDocumentUseCase()
    
    var body: some View {
        
        VStack{
            MasonryItemView(section: "", doc: DocumentItem(info: doc!), viewModel: DocumentListViewModel(prespective: .unread, store: StateStore.empty, usecase: uc))
        }
        .task {
            do {
                doc = try await uc.listUnreadDocuments(page: 1, pageSize: 1).first!
            } catch {
                print("Failed to load entry details: \(error)")
            }
        }
    }
}

#Preview {
    MasonryItemViewPreview()
}

#endif
