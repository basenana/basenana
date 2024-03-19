//
//  DocumentView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import Foundation
import SwiftUI


struct DocumentView: View {
    @State private var selectedItem: DocumentInfoViewModel?
    var docs: [DocumentInfoViewModel] = []
    
    init(docs: [DocumentInfoViewModel]) {
        self.docs = docs
    }
    
    var body: some View {
        NavigationView{
            List(docs, id: \.self, selection: $selectedItem) { document in
                NavigationLink {
                    Rectangle()
                        .fill(Color.white)
                        .overlay(
                            HTMLStringView(htmlContent: selectedItem?.content ?? "")
                        )
                        .frame(minWidth: 0, idealWidth: 1000, maxWidth: .infinity)
                        .layoutPriority(1)
                } label: {
                    DocumentItemView(doc: document)
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
        }
    }
}

struct DocumentItemView: View {
    var doc: DocumentInfoViewModel
    
    init(doc: DocumentInfoViewModel) {
        self.doc = doc
    }
    
    var body: some View {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }()
        let contentSwapper = { (content: String) -> String in
            let htmlCharFilterRegexp = try! NSRegularExpression(pattern: #"</?[!\w]+((\s+[\w-]+(\s*=\s*(?:\\*".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)/?>"#)
            
            var updatedContent = content.trimmingCharacters(in: .whitespaces)
            updatedContent = updatedContent.replacingOccurrences(of: "</p>", with: "</p>\n")
            updatedContent = updatedContent.replacingOccurrences(of: "</P>", with: "</P>\n")
            updatedContent = updatedContent.replacingOccurrences(of: "</div>", with: "</div>\n")
            updatedContent = updatedContent.replacingOccurrences(of: "</DIV>", with: "</DIV>\n")
            let range = NSRange(location: 0, length: updatedContent.utf16.count)
            let trimContent = htmlCharFilterRegexp.stringByReplacingMatches(in: updatedContent, options: [], range: range, withTemplate: "")
            
            let subContents = trimContent.split(separator: "\n")
            let result = subContents.prefix(5).joined(separator: "\n")
            return String(result)
        }
        
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(doc.name)
                    .font(.headline)
                
                Spacer()
                
                Text(dateFormatter.string(from: doc.createdAt))
                    .font(.caption)
            }
            Text(contentSwapper(doc.content))
                .font(.body)
                .foregroundColor(Color.gray)
                .frame(minWidth: 0, idealWidth: 200, maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 0, idealHeight: 50, alignment: .leading)
        }
        
    }
}

func buildDoc(id: Int64) -> DocumentInfoViewModel {
    var doc = DocumentInfo(
        id: id, oid: id + 100, name: "doc \(id)", parentEntryId: id + 200, content: "It is content for document \(id)",  createdAt: Date(), changedAt: Date())
    return DocumentInfoViewModel(doc: doc)
}

func buildDocs() -> [DocumentInfoViewModel] {
    var result: [DocumentInfoViewModel] = []
    for i in 1...10 {
        result.append(buildDoc(id: Int64(i)))
    }
    return result
}

#Preview {
    DocumentView(docs: buildDocs())
}
