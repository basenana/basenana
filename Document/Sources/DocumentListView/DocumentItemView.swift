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
    
    init(doc: DocumentItem, viewModel: DocumentListViewModel ) {
        self.doc = doc
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading){
                HStack(alignment: .top) {
                    Text("\(self.groupName().prefix(25))")
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text(self.docTime())
                        .font(.caption)
                        .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
                }
                
                Text(self.docTitle())
                    .font(.headline)
                    .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
                
            }
            
            Text("\(doc.info.subContent.prefix(100))")
                .font(.body)
                .foregroundColor(Color.gray)
                .frame(minWidth: 0, idealWidth: 200,  maxWidth: .infinity, minHeight: 0, idealHeight: 40, maxHeight: 50, alignment: .leading)
            
            Text(self.docURL())
                .foregroundColor(Color.gray)
        }
        .padding(.vertical, 3)
        .task {
            viewModel.initDocumentProperties(doc: doc)
        }
    }
    
    func getProperty(k: String) -> EntryProperty? {
        return viewModel.getDocumentProperties(docID: doc.id, key: k)
    }
    
    func docTitle() -> String {
        if let p = getProperty(k: Property.WebPageTitle){
            return p.value
        }
        
        return doc.info.name
    }
    
    func docTime() -> String {
        var datetime = doc.info.createdAt
        
        if let p = getProperty(k: Property.WebPageUpdateAt){
            // parse datetime from RFC3339
            if let paresedDate = rfc3339Formatter.date(from: p.value) {
                datetime = paresedDate
            }else {
                print("parse web page update at failed, got \(p.value)")
            }
        }
        
        return dateFormatter.string(from: datetime)
    }

    func docURL() -> String {
        var urlStr: String = ""
        for keyStr in [Property.WebPageURL, Property.WebSiteURL]{
            if let p = getProperty(k: keyStr){
                urlStr =  p.value
                break
            }
        }
        
        guard !urlStr.isEmpty else {
            return ""
        }
        
        return URL(string: urlStr)?.host() ?? ""
    }

    func groupName() -> String {
        if let p = getProperty(k: Property.WebSiteName){
            if p.value.count > 20 {
                return "\(p.value.prefix(20))..."
            }
            return p.value
        }
        
        return ""
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

