//
//  DocumentView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import Foundation
import SwiftUI


struct DocumentView: View {
    @State private var selectedItem: DocumentModel?
    @State private var docs: [DocumentModel] = []
    @State var isDrawerOpen: Bool = false
    @EnvironmentObject private var docService: DocumentService
    
    var body: some View {
        NavigationView{
            List(docs, id: \.self, selection: $selectedItem) { document in
                NavigationLink {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white)
                                .overlay(
                                    HTMLStringView(htmlContent: selectedItem?.content ?? "")
                                )
                                .frame(minWidth: 0, idealWidth: 1000, maxWidth: .infinity)
                            
                            Spacer()
                            ZStack {
                                if isDrawerOpen {
                                    Color.gray.edgesIgnoringSafeArea(.all)
                                }
                                
                                HStack {
                                    Spacer()
                                    VStack {
                                        Spacer()
                                        Button(action: { withAnimation { isDrawerOpen.toggle() } }) {
                                            Image(systemName: "ellipsis.message")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.trailing, 30)
                                    }
                                    .frame(width: 20)
                                    .padding()
                                    
                                    if isDrawerOpen {
                                        VStack {
                                            // Drawer content goes here
                                            Text("dialogue content")
                                                .padding()
                                        }
                                        .frame(width: 200)
                                        .background(Color.white)
                                    }
                                }
                            }
                            .frame(width: isDrawerOpen ? 205 : 5)
                            
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .layoutPriority(1)
                    }
                } label: {
                    DocumentItemView(doc: document)
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                docs = docService.listDocuments()
            }
        }
    }
}

struct DocumentItemView: View {
    var doc: DocumentModel
    
    init(doc: DocumentModel) {
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

//#Preview {
//    DocumentView(docs: buildDocs())
//}
