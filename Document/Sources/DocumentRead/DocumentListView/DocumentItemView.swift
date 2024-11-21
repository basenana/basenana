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
    var doc: DocumentItem
    var viewModel: DocumentListViewModel
    
    @State var parentEntry: EntryDetail? = nil
    @State var properties: [EntryProperty] = []

    init(doc: DocumentItem, viewModel: DocumentListViewModel ) {
        self.doc = doc
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading){
                HStack(alignment: .top) {
                    Text("\(groupName.prefix(25))")
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text(docTime)
                        .font(.caption)
                        .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
                }
                
                Text(docTitle)
                    .font(.headline)
                    .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
                
            }
            
            Text("\(doc.info.subContent.prefix(100))")
                .font(.body)
                .foregroundColor(Color.gray)
                .frame(minWidth: 0, idealWidth: 200,  maxWidth: .infinity, minHeight: 0, idealHeight: 40, maxHeight: 50, alignment: .leading)
            
            Text(docURL)
                .foregroundColor(Color.gray)
        }
        .padding(.vertical, 3)
        .task {
            if let entry = viewModel.getDocumentEntry(entry: doc.info.oid){
                properties = entry.properties
                parentEntry = viewModel.getDocumentEntry(entry: entry.parent)
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

