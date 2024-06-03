//
//  DocumentItemView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI

struct DocumentItemView: View {
    var doc: DocumentInfoModel
    var unreadPage: Bool
    @State var parent: EntryDetailModel?
    
    init(doc: DocumentInfoModel, unreadPage: Bool) {
        self.doc = doc
        self.unreadPage = unreadPage
    }
    
    var body: some View {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }()
        
        VStack(alignment: .leading) {
            VStack(alignment: .leading){
                
                HStack(alignment: .top) {
                    Text((parent?.name ?? "").hasPrefix(".") ? String((parent?.name ?? "").dropFirst(1)) : (parent?.name ?? ""))
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: doc.createdAt))
                        .font(.caption)
                        .foregroundColor(doc.unread || !unreadPage ? Color.primary : Color.gray)
                }
                
                Text(doc.name)
                    .font(.headline)
                    .foregroundColor(doc.unread || !unreadPage ? Color.primary : Color.gray)
                
            }
            Text(doc.subContent)
                .font(.body)
                .foregroundColor(Color.gray)
                .frame(minWidth: 0, idealWidth: 200, maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 0, idealHeight: 50, alignment: .leading)
        }
        .onAppear{
            Task.detached{
                let parentId = doc.parentId
                self.parent = entryService.getEntry(entryID: parentId)
            }
        }
    }
}

