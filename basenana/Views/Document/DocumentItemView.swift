//
//  DocumentItemView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI

struct DocumentItemView: View {
    var doc: DocumentInfoModel
    var markReaded: Bool
    
    @State var property = PropertyViewModel()
    @Environment(\.sendAlert) var sendAlert
    
    init(doc: DocumentInfoModel) {
        self.doc = doc
        self.markReaded = false
    }
    
    init(doc: DocumentInfoModel, markReaded: Bool ){
        self.doc = doc
        self.markReaded = markReaded
    }

    var body: some View {
        
        VStack(alignment: .leading) {
            VStack(alignment: .leading){
                
                HStack(alignment: .top) {
                    Text(self.groupName())
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text(self.docTime())
                        .font(.caption)
                        .foregroundColor(markReaded ? Color.gray : Color.primary  )
                }
                
                Text(self.docTitle())
                    .font(.headline)
                    .foregroundColor(markReaded ? Color.gray : Color.primary  )
                
            }
            
            Text("\(doc.subContent.prefix(100))")
                .font(.body)
                .foregroundColor(Color.gray)
                .frame(minWidth: 0, idealWidth: 200,  maxWidth: .infinity, minHeight: 0, idealHeight: 40, maxHeight: 50, alignment: .leading)
            
            Text(self.docURL())
                .foregroundColor(Color.gray)
        }
        .padding(.vertical, 3)
        .task {
            do {
                try await property.initEntry(entryID: doc.oid)
            } catch {
                sendAlert("fetch entry property failed \(error)")
            }
        }
    }
    
    func docTitle() -> String {
        if let p = property.getProperty(k: PropertyWebPageTitle){
            return p.value
        }
        
        return doc.name
    }
    
    func docTime() -> String {
        if let p = property.getProperty(k: PropertyWebPageUpdateAt){
            return p.value
        }
        
        return dateFormatter.string(from: doc.createdAt)
    }

    func docURL() -> String {
        var urlStr: String = ""
        for keyStr in [PropertyWebPageURL, PropertyWebSiteURL]{
            if let p = property.getProperty(k: keyStr){
                urlStr =  p.value
                break
            }
        }
        
        guard !urlStr.isEmpty else {
            return ""
        }
        
        let url = URL(string: urlStr)
        return url?.host() ?? ""
    }

    func groupName() -> String {
        if let p = property.getProperty(k: PropertyWebSiteName){
            return p.value
        }
        
        if !property.parentName.isEmpty && !property.parentName.hasPrefix("."){
            return property.parentName
        }
        
        return property.entryAliases
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

