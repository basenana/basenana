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
                        ZStack(alignment: .bottomTrailing) {
                            HStack{
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .overlay(
                                        HTMLStringView(htmlContent: selectedItem?.content ?? "")
                                    )
                                    .frame(minWidth: 0, idealWidth: 1000)
                                
                                DrawerView(isDrawerOpen: $isDrawerOpen)
                                    .frame(width: isDrawerOpen ? 200 : 5)
                            }
                            
                            
                            Button(action: {
                                isDrawerOpen.toggle()
                            }, label: {
                                Image(systemName: "ellipsis.message")
                                    .resizable()
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        ZStack{
                                            Color.white
                                                .clipShape(RoundedCorners(tl: 60, tr: 0, bl: 60, br: 0))
                                        }
                                    )
                            })
                            .padding()
                            .offset(x: isDrawerOpen ? -195 : 5, y: 0)
                            
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

struct DrawerView: View {
    @Binding var isDrawerOpen: Bool
    
    var body: some View {
        VStack {
            Text("dialogue content")
                .padding(10)
        }
        .background(Color.white)
        .frame( width: isDrawerOpen ? 200:5)
        
    }
}

struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        
        return path
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
