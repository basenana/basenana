//
//  NavigationItemView.swift
//  Document
//
//  Created by Hypo on 2024/12/7.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import AppState
import Entities


struct NavigationItemView: View {
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
            VStack(alignment: .leading){
                
                HStack(alignment: .top) {
                    Text("\(self.groupName.prefix(25))")
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text(self.docTime)
                        .font(.caption)
                        .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
                }
                
                Text(self.docTitle)
                    .font(.headline)
                    .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
                
            }
            
            Text("\(doc.info.subContent.prefix(100))")
                .font(.body)
                .foregroundColor(Color.gray)
                .frame(minWidth: 0, idealWidth: 200,  maxWidth: .infinity, minHeight: 0, idealHeight: 40, maxHeight: 50, alignment: .leading)
            
            Text(self.docURL)
                .foregroundColor(Color.gray)
        }
        .padding(.vertical, 3)
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
